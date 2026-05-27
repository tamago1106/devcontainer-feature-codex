#!/usr/bin/env bash
set -euo pipefail

USERNAME="${_REMOTE_USER:-${USERNAME:-vscode}}"
USER_HOME="${USER_HOME:-$(getent passwd "${USERNAME}" | cut -d: -f6 || true)}"
CODEX_SESSION_DIR="${CODEX_SESSION_DIR:-/mnt/codex-session}"
SESSIONSOURCE="${SESSIONSOURCE:-container}"

if [ -z "${USER_HOME}" ]; then
    USER_HOME="/home/${USERNAME}"
fi

mkdir -p "${CODEX_SESSION_DIR}" "${USER_HOME}"
chown "${USERNAME}:${USERNAME}" "${CODEX_SESSION_DIR}" "${USER_HOME}" 2>/dev/null || true

CONTAINER_CODEX_DIR="${USER_HOME}/.codex"

is_non_empty_dir() {
    [ -d "$1" ] && [ -n "$(find "$1" -mindepth 1 -maxdepth 1 -print -quit)" ]
}

link_container_codex_dir() {
    if [ ! -e "${CONTAINER_CODEX_DIR}" ] && [ ! -L "${CONTAINER_CODEX_DIR}" ]; then
        ln -s "${CODEX_SESSION_DIR}" "${CONTAINER_CODEX_DIR}"
        chown -h "${USERNAME}:${USERNAME}" "${CONTAINER_CODEX_DIR}" 2>/dev/null || true
    fi
}

use_container_session() {
    if [ -L "${CONTAINER_CODEX_DIR}" ]; then
        rm "${CONTAINER_CODEX_DIR}"
    elif is_non_empty_dir "${CONTAINER_CODEX_DIR}"; then
        local backup_parent
        local backup_codex_dir

        if is_non_empty_dir "${CODEX_SESSION_DIR}"; then
            echo "Error: ${CODEX_SESSION_DIR} already contains a Codex session; refusing to overwrite it." >&2
            exit 1
        fi

        backup_parent="$(mktemp -d "${USER_HOME}/.codex.devcontainer-feature-backup.XXXXXX")"
        backup_codex_dir="${backup_parent}/.codex"

        mv "${CONTAINER_CODEX_DIR}" "${backup_codex_dir}"
        cp -a "${backup_codex_dir}/." "${CODEX_SESSION_DIR}/"
        rm -rf "${backup_parent}"
    elif [ -d "${CONTAINER_CODEX_DIR}" ]; then
        rmdir "${CONTAINER_CODEX_DIR}"
    elif [ -e "${CONTAINER_CODEX_DIR}" ]; then
        echo "Error: ${CONTAINER_CODEX_DIR} exists and is not a directory or symlink." >&2
        exit 1
    fi

    link_container_codex_dir
}

case "${SESSIONSOURCE}" in
    container)
        use_container_session
        ;;
    *)
        echo "Error: sessionSource must be 'container'." >&2
        exit 1
        ;;
esac

if [ ! -L "${CONTAINER_CODEX_DIR}" ]; then
    echo "Error: failed to link ${CONTAINER_CODEX_DIR} to ${CODEX_SESSION_DIR}." >&2
    exit 1
fi

if [ "$(readlink "${CONTAINER_CODEX_DIR}")" != "${CODEX_SESSION_DIR}" ]; then
    rm "${CONTAINER_CODEX_DIR}"
    ln -s "${CODEX_SESSION_DIR}" "${CONTAINER_CODEX_DIR}"
    chown -h "${USERNAME}:${USERNAME}" "${CONTAINER_CODEX_DIR}" 2>/dev/null || true
fi

echo "OpenAI Codex devcontainer feature installed."
echo "Codex session: ${CONTAINER_CODEX_DIR} -> ${CODEX_SESSION_DIR}"
echo "Session source: ${SESSIONSOURCE}"
