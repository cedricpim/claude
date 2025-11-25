# Claude Docker Container

Docker container for running Claude CLI with persistent credentials.

## Building the Image

```bash
docker build -t claude-cli .
```

## Usage

### With Makefile (Recommended)

The easiest way to use this container:

```bash
# Build the image
make build

# Run Claude CLI
make claude

# Open bash shell in container
make shell

# Check token usage
make usage

# See all available commands
make help
```

All Makefile commands automatically mount `~/.claude.json` for credential persistence.

### With docker run

For interactive Claude sessions:

```bash
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v ~/.claude.json:/.claude.json \
  -v "$(pwd)":/app \
  -w /app \
  -e HOME=/app \
  claude-cli claude
```

For specific commands:

```bash
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v ~/.claude.json:/.claude.json \
  -v "$(pwd)":/app \
  -w /app \
  -e HOME=/app \
  claude-cli claude <command>
```

### Docker Options Explained

- `--user $(id -u):$(id -g)` - Run as your host user to avoid permission issues with created files
- `-v ~/.claude.json:/.claude.json` - Persists Claude credentials on your host. The file will be created on first run when you authenticate.
- `-v "$(pwd)":/app` - Mounts your current directory into the container
- `-w /app` - Sets the working directory inside the container
- `-e HOME=/app` - Sets HOME so Claude can find config files

## First Run

On first run, if `~/.claude.json` doesn't exist:
1. The volume mount will create it as an empty file
2. Claude will prompt for authentication
3. Credentials are saved to `~/.claude.json` on your host
4. Future container runs will reuse these credentials

## Sharing Credentials Across Containers

Since credentials are stored in `~/.claude.json` on the host, multiple containers can share the same authentication by mounting the same file.

## File Permissions

All containers run as your host user (using `--user $(id -u):$(id -g)`) to prevent permission issues. This means:
- Files created or modified by Claude in the container are owned by your host user, not root
- You can edit files created by Claude without needing sudo
- No permission conflicts when switching between host and container
