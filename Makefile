.PHONY: build run shell attach clean usage help

IMAGE_NAME := claude-arch
CONTAINER_NAME := claude-container

# Configuration variables with defaults
DOCKER_CMD := $(or $(DOCKER_CMD),docker run)
COMPOSE_SERVICE := $(or $(COMPOSE_SERVICE),claude)
COMPOSE_PATH := $(or $(COMPOSE_PATH),.)

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run Claude with interactive terminal
run:
	@if [ "$(DOCKER_CMD)" = "docker run" ]; then \
		docker run -it --rm \
			--user $(shell id -u):$(shell id -g) \
			-v $(HOME)/.claude.json:/.claude.json \
			-v $(PWD):/workspace \
			-w /workspace \
			-e HOME=/workspace \
			--name $(CONTAINER_NAME) \
			$(IMAGE_NAME) /bin/bash; \
	else \
		docker-compose -f $(COMPOSE_PATH)/docker-compose.yml exec $(COMPOSE_SERVICE) /bin/bash; \
	fi

# Run Claude CLI directly
claude:
	@if [ "$(DOCKER_CMD)" = "docker run" ]; then \
		docker run -it --rm \
			--user $(shell id -u):$(shell id -g) \
			-v $(HOME)/.claude.json:/.claude.json \
			-v $(PWD):/workspace \
			-w /workspace \
			-e HOME=/workspace \
			$(IMAGE_NAME) claude; \
	else \
		docker-compose -f $(COMPOSE_PATH)/docker-compose.yml exec $(COMPOSE_SERVICE) claude; \
	fi

# Open shell in container
shell:
	@if [ "$(DOCKER_CMD)" = "docker run" ]; then \
		docker run -it --rm \
			--user $(shell id -u):$(shell id -g) \
			-v $(HOME)/.claude.json:/.claude.json \
			-v $(PWD):/workspace \
			-w /workspace \
			-e HOME=/workspace \
			$(IMAGE_NAME) /bin/bash; \
	else \
		docker-compose -f $(COMPOSE_PATH)/docker-compose.yml exec $(COMPOSE_SERVICE) /bin/bash; \
	fi

# Attach to existing docker-compose claude service
attach:
	docker-compose -f $(COMPOSE_PATH)/docker-compose.yml attach $(COMPOSE_SERVICE)

# Check token usage with live monitoring
usage:
	@if [ "$(DOCKER_CMD)" = "docker run" ]; then \
		docker run -it --rm \
			--user $(shell id -u):$(shell id -g) \
			-v $(HOME)/.claude.json:/.claude.json \
			-v $(PWD):/workspace \
			-w /workspace \
			-e HOME=/workspace \
			$(IMAGE_NAME) bunx ccusage@latest blocks --live; \
	else \
		docker-compose -f $(COMPOSE_PATH)/docker-compose.yml exec $(COMPOSE_SERVICE) bunx ccusage@latest blocks --live; \
	fi

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
	@echo "  attach    - Attach to existing docker-compose claude service"
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
	@echo "Environment variables:"
	@echo "  DOCKER_CMD=docker-compose - Use docker-compose instead of docker run"
	@echo "  COMPOSE_SERVICE=claude    - Service name for docker-compose (default: claude)"
	@echo "  COMPOSE_PATH=path         - Path to docker-compose.yml directory (default: .)"
	@echo ""
	@echo "Examples:"
	@echo "  Standalone: make claude"
	@echo "  Docker-compose: DOCKER_CMD=docker-compose COMPOSE_PATH=.devcontainers make claude"
