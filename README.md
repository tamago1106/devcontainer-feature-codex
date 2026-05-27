# devcontainer-feature-codex

A Dev Container Feature for using OpenAI Codex inside VS Code dev containers.

## Features

- Installs the OpenAI Codex VS Code extension: `OpenAI.chatgpt`
- Mounts a devcontainer-specific Docker volume so sessions and auth state can persist across container rebuilds
- Links the container user's `~/.codex` to the mounted Codex session directory

## Usage

```jsonc
{
  "features": {
    "ghcr.io/tamago1106/devcontainer-feature-codex/codex:0.1.0": {}
  }
}
```

By default, the feature stores the Codex session in a Docker volume scoped to this dev container. It links the remote user's `~/.codex` to `/mnt/codex-session`:

```jsonc
{
  "source": "devcontainer-codex-${devcontainerId}",
  "target": "/mnt/codex-session",
  "type": "volume"
}
```

## Options

### `sessionSource`

Controls where the Codex session is stored. Currently only `container` is supported.

```jsonc
{
  "features": {
    "ghcr.io/tamago1106/devcontainer-feature-codex/codex:0.1.0": {
      "sessionSource": "container"
    }
  }
}
```

- `container` uses a Docker volume named with `${devcontainerId}`. The session survives container rebuilds/recreates, but is not shared with the host or with other dev containers.
- If a non-empty container `~/.codex` exists and the mounted session volume is empty, the feature migrates it into `/mnt/codex-session`. It refuses to overwrite a non-empty mounted session volume.

## Local Testing

This repository follows the structure used by [`devcontainers/feature-starter`](https://github.com/devcontainers/feature-starter).

```sh
devcontainer features test --features codex --base-image mcr.microsoft.com/devcontainers/base:ubuntu .
```
