FROM archlinux:latest

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

# Create a non-root user
RUN useradd -m -s /bin/bash claude-user

# Switch to non-root user
USER claude-user
WORKDIR /home/claude-user

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Add Bun and local bin to PATH
ENV PATH="/home/claude-user/.local/bin:/home/claude-user/.bun/bin:$PATH"

# Install Claude CLI via official install script
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install ccusage globally with Bun
RUN bun install -g ccusage@latest

# Create config directory
RUN mkdir -p /home/claude-user/.config/claude

# Copy Claude credentials from host
COPY --chown=claude-user:claude-user .claude.json /home/claude-user/.claude.json
COPY --chown=claude-user:claude-user .claude /home/claude-user/.claude

# Set the default command
CMD ["claude", "--help"]
