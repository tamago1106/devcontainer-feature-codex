#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEST_ROOT}"' EXIT

USERNAME="$(id -un)"

HOST_BIND_HOME="${TEST_ROOT}/host-bind-home"
HOST_CODEX_DIR="${TEST_ROOT}/host-codex"
mkdir -p "${HOST_BIND_HOME}" "${HOST_CODEX_DIR}"
printf 'host-session\n' > "${HOST_CODEX_DIR}/session.json"

USER_HOME="${HOST_BIND_HOME}" HOST_CODEX_DIR="${HOST_CODEX_DIR}" USERNAME="${USERNAME}" ./src/codex/install.sh

if [ ! -L "${HOST_BIND_HOME}/.codex" ]; then
    echo "Expected host bind mode to create a .codex symlink"
    exit 1
fi

if [ "$(readlink "${HOST_BIND_HOME}/.codex")" != "${HOST_CODEX_DIR}" ]; then
    echo "Expected host bind mode .codex to point to ${HOST_CODEX_DIR}"
    exit 1
fi

if [ "$(cat "${HOST_BIND_HOME}/.codex/session.json")" != "host-session" ]; then
    echo "Expected host bind mode to expose the host Codex session"
    exit 1
fi

BROKEN_SYMLINK_HOME="${TEST_ROOT}/broken-symlink-home"
BROKEN_SYMLINK_HOST_CODEX_DIR="${TEST_ROOT}/broken-symlink-host-codex"
mkdir -p "${BROKEN_SYMLINK_HOME}" "${BROKEN_SYMLINK_HOST_CODEX_DIR}"
ln -s "${TEST_ROOT}/missing-host-codex" "${BROKEN_SYMLINK_HOME}/.codex"

USER_HOME="${BROKEN_SYMLINK_HOME}" HOST_CODEX_DIR="${BROKEN_SYMLINK_HOST_CODEX_DIR}" USERNAME="${USERNAME}" ./src/codex/install.sh

if [ ! -L "${BROKEN_SYMLINK_HOME}/.codex" ]; then
    echo "Expected host bind mode to replace a broken .codex symlink"
    exit 1
fi

if [ "$(readlink "${BROKEN_SYMLINK_HOME}/.codex")" != "${BROKEN_SYMLINK_HOST_CODEX_DIR}" ]; then
    echo "Expected broken symlink replacement to point to ${BROKEN_SYMLINK_HOST_CODEX_DIR}"
    exit 1
fi

EXISTING_HOME="${TEST_ROOT}/existing-home"
EXISTING_HOST_CODEX_DIR="${TEST_ROOT}/existing-host-codex"
mkdir -p "${EXISTING_HOME}/.codex" "${EXISTING_HOST_CODEX_DIR}"
printf 'container-session\n' > "${EXISTING_HOME}/.codex/session.json"
printf 'host-session\n' > "${EXISTING_HOST_CODEX_DIR}/session.json"

if USER_HOME="${EXISTING_HOME}" HOST_CODEX_DIR="${EXISTING_HOST_CODEX_DIR}" USERNAME="${USERNAME}" ./src/codex/install.sh >/dev/null 2>&1; then
    echo "Expected host bind mode to refuse overwriting an existing .codex directory"
    exit 1
fi

if [ ! -d "${EXISTING_HOME}/.codex" ]; then
    echo "Expected failed install to leave the existing container .codex in place"
    exit 1
fi

if [ "$(cat "${EXISTING_HOST_CODEX_DIR}/session.json")" != "host-session" ]; then
    echo "Expected failed install to preserve the host Codex session"
    exit 1
fi

echo "Codex host bind session behaved as expected"
