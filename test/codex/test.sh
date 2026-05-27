#!/usr/bin/env bash
set -euo pipefail

if [ ! -L "${HOME}/.codex" ]; then
    echo "Expected ${HOME}/.codex to be a symlink"
    exit 1
fi

if [ "$(readlink "${HOME}/.codex")" != "/mnt/codex-host" ]; then
    echo "Expected ${HOME}/.codex to point to /mnt/codex-host"
    exit 1
fi

if [ ! -d "/mnt/codex-host" ]; then
    echo "Expected /mnt/codex-host to exist"
    exit 1
fi

if [ ! -d "${HOME}/.codex" ]; then
    echo "Expected ${HOME}/.codex to exist"
    exit 1
fi

echo "Codex session exists at ${HOME}/.codex -> /mnt/codex-host"
