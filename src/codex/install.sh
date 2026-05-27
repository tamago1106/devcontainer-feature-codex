#!/usr/bin/env bash
set -euo pipefail

USERNAME="${_REMOTE_USER:-${USERNAME:-vscode}}"
USER_HOME="${USER_HOME:-$(getent passwd "${USERNAME}" | cut -d: -f6 || true)}"
HOST_CODEX_DIR="${HOST_CODEX_DIR:-/mnt/codex-host}"

if [ -z "${USER_HOME}" ]; then
    USER_HOME="/home/${USERNAME}"
fi

mkdir -p "${HOST_CODEX_DIR}" "${USER_HOME}"
chown "${USERNAME}:${USERNAME}" "${HOST_CODEX_DIR}" "${USER_HOME}" 2>/dev/null || true

CONTAINER_CODEX_DIR="${USER_HOME}/.codex"

if [ -L "${CONTAINER_CODEX_DIR}" ]; then
    rm "${CONTAINER_CODEX_DIR}"
elif [ -e "${CONTAINER_CODEX_DIR}" ]; then
    echo "Error: ${CONTAINER_CODEX_DIR} already exists. Remove it before installing this feature." >&2
    exit 1
fi

ln -s "${HOST_CODEX_DIR}" "${CONTAINER_CODEX_DIR}"
chown -h "${USERNAME}:${USERNAME}" "${CONTAINER_CODEX_DIR}" 2>/dev/null || true

if [ ! -L "${CONTAINER_CODEX_DIR}" ]; then
    echo "Error: failed to link ${CONTAINER_CODEX_DIR} to ${HOST_CODEX_DIR}." >&2
    exit 1
fi

if [ "$(readlink "${CONTAINER_CODEX_DIR}")" != "${HOST_CODEX_DIR}" ]; then
    rm "${CONTAINER_CODEX_DIR}"
    ln -s "${HOST_CODEX_DIR}" "${CONTAINER_CODEX_DIR}"
    chown -h "${USERNAME}:${USERNAME}" "${CONTAINER_CODEX_DIR}" 2>/dev/null || true
fi

echo "OpenAI Codex devcontainer feature installed."
echo "Codex session: ${CONTAINER_CODEX_DIR} -> ${HOST_CODEX_DIR}"
