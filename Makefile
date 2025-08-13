.PHONY: build run shell attach clean usage help copy-creds

IMAGE_NAME := claude-arch
CONTAINER_NAME := claude-container

# Configuration variables with defaults
DOCKER_CMD := $(or $(DOCKER_CMD),docker run)
COMPOSE_SERVICE := $(or $(COMPOSE_SERVICE),claude)
COMPOSE_PATH := $(or $(COMPOSE_PATH),.)
CREDENTIALS_SOURCE := $(or $(CREDENTIALS_SOURCE),$(HOME))
CREDENTIALS_TARGET := $(or $(CREDENTIALS_TARGET),.)

# Copy Claude credentials to target directory
copy-creds:
	@if [ -f $(CREDENTIALS_SOURCE)/.claude.json ]; then \
		cp $(CREDENTIALS_SOURCE)/.claude.json $(CREDENTIALS_TARGET)/.claude.json; \
		echo "Copied $(CREDENTIALS_SOURCE)/.claude.json to $(CREDENTIALS_TARGET)/.claude.json"; \
	else \
		echo "Warning: $(CREDENTIALS_SOURCE)/.claude.json not found"; \
	fi
	@if [ -d $(CREDENTIALS_SOURCE)/.claude ]; then \
		cp -r $(CREDENTIALS_SOURCE)/.claude $(CREDENTIALS_TARGET)/.claude; \
		echo "Copied $(CREDENTIALS_SOURCE)/.claude directory to $(CREDENTIALS_TARGET)/.claude"; \
	else \
		echo "Warning: $(CREDENTIALS_SOURCE)/.claude directory not found"; \
	fi

# Build the Docker image (copy credentials first)
build: copy-creds
	docker build -t $(IMAGE_NAME) .

# Run Claude with interactive terminal
run:
	@if [ "$(DOCKER_CMD)" = "docker run" ]; then \
		docker run -it --rm \
			-v $(HOME)/.config/claude:/root/.config/claude \
			-v $(PWD):/workspace \
			-w /workspace \
			--name $(CONTAINER_NAME) \
			$(IMAGE_NAME) /bin/bash; \
	else \
		docker-compose -f $(COMPOSE_PATH)/docker-compose.yml exec $(COMPOSE_SERVICE) /bin/bash; \
	fi

# Run Claude CLI directly
claude:
	@if [ "$(DOCKER_CMD)" = "docker run" ]; then \
		docker run -it --rm \
			-v $(HOME)/.config/claude:/root/.config/claude \
			-v $(PWD):/workspace \
			-w /workspace \
			$(IMAGE_NAME) claude; \
	else \
		docker-compose -f $(COMPOSE_PATH)/docker-compose.yml exec $(COMPOSE_SERVICE) claude; \
	fi

# Open shell in container
shell:
	@if [ "$(DOCKER_CMD)" = "docker run" ]; then \
		docker run -it --rm \
			-v $(HOME)/.config/claude:/root/.config/claude \
			-v $(PWD):/workspace \
			-w /workspace \
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
			-v $(HOME)/.config/claude:/root/.config/claude \
			-v $(PWD):/workspace \
			-w /workspace \
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
	@echo "  copy-creds - Copy Claude credentials to target directory"
	@echo "  build     - Build the Docker image (includes copy-creds)"
	@echo "  run       - Run container with interactive bash shell"
	@echo "  claude    - Run Claude CLI directly"
	@echo "  shell     - Open bash shell in container"
	@echo "  attach    - Attach to existing docker-compose claude service"
	@echo "  usage     - Monitor token usage with bunx ccusage --live"
	@echo "  clean     - Remove Docker image and prune system"
	@echo "  clean-all - Remove all containers, images, and system prune"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  DOCKER_CMD=docker-compose - Use docker-compose instead of docker run"
	@echo "  COMPOSE_SERVICE=claude    - Service name for docker-compose (default: claude)"
	@echo "  COMPOSE_PATH=path         - Path to docker-compose.yml directory (default: .)"
	@echo "  CREDENTIALS_SOURCE=path   - Source directory for credentials (default: $$HOME)"
	@echo "  CREDENTIALS_TARGET=path   - Target directory for credentials (default: .)"
	@echo ""
	@echo "Examples:"
	@echo "  Standalone: make claude"
	@echo "  Docker-compose: DOCKER_CMD=docker-compose COMPOSE_PATH=.devcontainers make claude"