#!/usr/bin/env bash
set -euo pipefail

if [ ! -L "${HOME}/.codex" ]; then
    echo "Expected ${HOME}/.codex to be a symlink"
    exit 1
fi

if [ "$(readlink "${HOME}/.codex")" != "/mnt/codex-session" ]; then
    echo "Expected ${HOME}/.codex to point to /mnt/codex-session"
    exit 1
fi

if [ ! -d "/mnt/codex-session" ]; then
    echo "Expected /mnt/codex-session to exist"
    exit 1
fi

if [ ! -d "${HOME}/.codex" ]; then
    echo "Expected ${HOME}/.codex to exist"
    exit 1
fi

echo "Codex session exists at ${HOME}/.codex -> /mnt/codex-session"
