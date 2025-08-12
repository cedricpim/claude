FROM archlinux:latest

# Build argument for credentials directory
ARG BUILD_CONTEXT_DIR=.

# Update system and install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    curl \
    ca-certificates \
    npm \
    python \
    python-pip \
    git \
    base-devel \
    unzip

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Add Bun and local bin to PATH
ENV PATH="/root/.local/bin:/root/.bun/bin:$PATH"

# Install Claude CLI via official install script
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install ccusage globally with Bun
RUN bun install -g ccusage@latest

# Create config directory
RUN mkdir -p /root/.config/claude

# Copy Claude credentials from host
COPY ${BUILD_CONTEXT_DIR}/.claude.json /root/.claude.json
COPY ${BUILD_CONTEXT_DIR}/.claude /root/.claude

# Set the default command
CMD ["claude", "--help"]
