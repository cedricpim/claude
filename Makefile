.PHONY: build run shell clean usage help copy-creds

IMAGE_NAME := claude-arch
CONTAINER_NAME := claude-container

# Copy Claude credentials to current directory
copy-creds:
	@if [ -f $(HOME)/.claude.json ]; then \
		cp $(HOME)/.claude.json .claude.json; \
		echo "Copied ~/.claude.json to .claude.json"; \
	else \
		echo "Warning: ~/.claude.json not found"; \
	fi
	@if [ -d $(HOME)/.claude ]; then \
		cp -r $(HOME)/.claude .claude; \
		echo "Copied ~/.claude directory to .claude"; \
	else \
		echo "Warning: ~/.claude directory not found"; \
	fi

# Build the Docker image (copy credentials first)
build: copy-creds
	docker build -t $(IMAGE_NAME) .

# Run Claude with interactive terminal
run:
	docker run -it --rm \
		-v $(HOME)/.config/claude:/home/claude-user/.config/claude \
		-v $(PWD):/workspace \
		-w /workspace \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME) /bin/bash

# Run Claude CLI directly
claude:
	docker run -it --rm \
		-v $(HOME)/.config/claude:/home/claude-user/.config/claude \
		-v $(PWD):/workspace \
		-w /workspace \
		$(IMAGE_NAME) claude

# Open shell in container
shell:
	docker run -it --rm \
		-v $(HOME)/.config/claude:/home/claude-user/.config/claude \
		-v $(PWD):/workspace \
		-w /workspace \
		$(IMAGE_NAME) /bin/bash

# Check token usage with live monitoring
usage:
	docker run -it --rm \
		-v $(HOME)/.config/claude:/home/claude-user/.config/claude \
		-v $(PWD):/workspace \
		-w /workspace \
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
	@echo "  copy-creds - Copy Claude credentials from ~ to current directory"
	@echo "  build     - Build the Docker image (includes copy-creds)"
	@echo "  run       - Run container with interactive bash shell"
	@echo "  claude    - Run Claude CLI directly"
	@echo "  shell     - Open bash shell in container"
	@echo "  usage     - Monitor token usage with bunx ccusage --live"
	@echo "  clean     - Remove Docker image and prune system"
	@echo "  clean-all - Remove all containers, images, and system prune"
	@echo "  help      - Show this help message"