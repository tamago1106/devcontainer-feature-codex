
# OpenAI Codex (codex)

Installs the OpenAI Codex VS Code extension and persists Codex sessions in a devcontainer-specific Docker volume.

## Example Usage

```json
"features": {
    "ghcr.io/tamago1106/devcontainer-feature-codex/codex:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| sessionSource | Use a Codex session stored in a Docker volume scoped to this dev container. The session persists across container rebuilds/recreates, but is not shared with the host or other dev containers. | string | container |

## Customizations

### VS Code Extensions

- `OpenAI.chatgpt`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/tamago1106/devcontainer-feature-codex/blob/main/src/codex/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
