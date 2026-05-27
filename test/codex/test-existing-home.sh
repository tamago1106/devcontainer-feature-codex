#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEST_ROOT}"' EXIT

USERNAME="$(id -un)"

CONTAINER_MODE_HOME="${TEST_ROOT}/container-mode-home"
CONTAINER_MODE_SESSION_DIR="${TEST_ROOT}/container-mode-codex-session"
mkdir -p "${CONTAINER_MODE_HOME}/.codex" "${CONTAINER_MODE_SESSION_DIR}"
printf 'container-session\n' > "${CONTAINER_MODE_HOME}/.codex/session.json"

USER_HOME="${CONTAINER_MODE_HOME}" CODEX_SESSION_DIR="${CONTAINER_MODE_SESSION_DIR}" USERNAME="${USERNAME}" SESSIONSOURCE="container" ./src/codex/install.sh

if [ ! -L "${CONTAINER_MODE_HOME}/.codex" ]; then
    echo "Expected container mode to replace existing container .codex with a symlink"
    exit 1
fi

if [ "$(readlink "${CONTAINER_MODE_HOME}/.codex")" != "${CONTAINER_MODE_SESSION_DIR}" ]; then
    echo "Expected container mode .codex to point to ${CONTAINER_MODE_SESSION_DIR}"
    exit 1
fi

if [ "$(cat "${CONTAINER_MODE_SESSION_DIR}/session.json")" != "container-session" ]; then
    echo "Expected container mode to persist the container Codex session"
    exit 1
fi

BROKEN_SYMLINK_HOME="${TEST_ROOT}/broken-symlink-home"
BROKEN_SYMLINK_SESSION_DIR="${TEST_ROOT}/broken-symlink-codex-session"
mkdir -p "${BROKEN_SYMLINK_HOME}" "${BROKEN_SYMLINK_SESSION_DIR}"
ln -s "${TEST_ROOT}/missing-codex-session" "${BROKEN_SYMLINK_HOME}/.codex"

USER_HOME="${BROKEN_SYMLINK_HOME}" CODEX_SESSION_DIR="${BROKEN_SYMLINK_SESSION_DIR}" USERNAME="${USERNAME}" SESSIONSOURCE="container" ./src/codex/install.sh

if [ ! -L "${BROKEN_SYMLINK_HOME}/.codex" ]; then
    echo "Expected container mode to replace a broken .codex symlink"
    exit 1
fi

if [ "$(readlink "${BROKEN_SYMLINK_HOME}/.codex")" != "${BROKEN_SYMLINK_SESSION_DIR}" ]; then
    echo "Expected broken symlink replacement to point to ${BROKEN_SYMLINK_SESSION_DIR}"
    exit 1
fi

EXISTING_VOLUME_HOME="${TEST_ROOT}/existing-volume-home"
EXISTING_VOLUME_SESSION_DIR="${TEST_ROOT}/existing-volume-codex-session"
mkdir -p "${EXISTING_VOLUME_HOME}/.codex" "${EXISTING_VOLUME_SESSION_DIR}"
printf 'container-session\n' > "${EXISTING_VOLUME_HOME}/.codex/session.json"
printf 'volume-session\n' > "${EXISTING_VOLUME_SESSION_DIR}/session.json"

if USER_HOME="${EXISTING_VOLUME_HOME}" CODEX_SESSION_DIR="${EXISTING_VOLUME_SESSION_DIR}" USERNAME="${USERNAME}" SESSIONSOURCE="container" ./src/codex/install.sh >/dev/null 2>&1; then
    echo "Expected container mode to refuse overwriting an existing Codex volume"
    exit 1
fi

if [ ! -d "${EXISTING_VOLUME_HOME}/.codex" ]; then
    echo "Expected failed migration to leave the existing container .codex in place"
    exit 1
fi

if [ "$(cat "${EXISTING_VOLUME_SESSION_DIR}/session.json")" != "volume-session" ]; then
    echo "Expected failed migration to preserve the existing Codex volume"
    exit 1
fi

echo "Codex container session behaved as expected"
