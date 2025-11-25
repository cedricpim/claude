.PHONY: build run shell clean usage help

IMAGE_NAME := claude-arch
CONTAINER_NAME := claude-container

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run Claude with interactive terminal
run:
	docker run -it --rm \
		--user $(shell id -u):$(shell id -g) \
		-v $(HOME)/.claude.json:/.claude.json \
		-v $(PWD):/workspace \
		-w /workspace \
		-e HOME=/workspace \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME) /bin/bash

# Run Claude CLI directly
claude:
	docker run -it --rm \
		--user $(shell id -u):$(shell id -g) \
		-v $(HOME)/.claude.json:/.claude.json \
		-v $(PWD):/workspace \
		-w /workspace \
		-e HOME=/workspace \
		$(IMAGE_NAME) claude

# Open shell in container
shell:
	docker run -it --rm \
		--user $(shell id -u):$(shell id -g) \
		-v $(HOME)/.claude.json:/.claude.json \
		-v $(PWD):/workspace \
		-w /workspace \
		-e HOME=/workspace \
		$(IMAGE_NAME) /bin/bash

# Check token usage with live monitoring
usage:
	docker run -it --rm \
		--user $(shell id -u):$(shell id -g) \
		-v $(HOME)/.claude.json:/.claude.json \
		-v $(PWD):/workspace \
		-w /workspace \
		-e HOME=/workspace \
		$(IMAGE_NAME) bunx ccusage@latest blocks --live

# Clean up Docker resources
clean:
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	docker system prune -f

# Remove all containers and images
clean-all:
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	docker system prune -af

# Show help
help:
	@echo "Available commands:"
	@echo "  build     - Build the Docker image"
	@echo "  run       - Run container with interactive bash shell"
	@echo "  claude    - Run Claude CLI directly"
	@echo "  shell     - Open bash shell in container"
	@echo "  usage     - Monitor token usage with bunx ccusage --live"
	@echo "  clean     - Remove Docker image and prune system"
	@echo "  clean-all - Remove all containers, images, and system prune"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Credentials:"
	@echo "  Claude credentials are stored in ~/.claude.json on the host"
	@echo "  This file is automatically mounted into containers and persists across runs"
	@echo "  On first run, Claude will prompt for authentication"
	@echo ""
	@echo "File Permissions:"
	@echo "  All containers run as your host user (UID:GID) to avoid permission issues"
	@echo "  Files created by Claude will be owned by your host user, not root"
	@echo ""
	@echo "Examples:"
	@echo "  make claude"
