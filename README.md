# devcontainer-feature-codex

A Dev Container Feature for using OpenAI Codex inside VS Code dev containers.

## Features

- Installs the OpenAI Codex VS Code extension: `OpenAI.chatgpt`
- Bind-mounts the host user's `~/.codex` into the dev container
- Links the container user's `~/.codex` to the mounted host Codex directory

## Usage

```jsonc
{
  "features": {
    "ghcr.io/tamago1106/devcontainer-feature-codex/codex:0.1.0": {}
  }
}
```

The feature bind-mounts the host user's `~/.codex` into the dev container and links the remote user's `~/.codex` to `/mnt/codex-host`:

```jsonc
{
  "source": "${localEnv:HOME}${localEnv:USERPROFILE}/.codex",
  "target": "/mnt/codex-host",
  "type": "bind"
}
```

There are no feature options. If the container user's `~/.codex` already exists as a regular file or directory, remove it before installing this feature.

## Local Testing

This repository follows the structure used by [`devcontainers/feature-starter`](https://github.com/devcontainers/feature-starter).

```sh
devcontainer features test --features codex --base-image mcr.microsoft.com/devcontainers/base:ubuntu .
```
