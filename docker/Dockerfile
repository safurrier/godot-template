FROM rust:1.92-slim-bookworm

# Install system dependencies for Godot and general tooling
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    make \
    python3 \
    python3-pip \
    python3-venv \
    libx11-6 \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxi6 \
    libgl1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Install Rust components
RUN rustup component add clippy rustfmt

# Install uv for Python package management
RUN pip3 install --break-system-packages uv

# Install Godot 4.5.1 headless (architecture-aware)
ENV GODOT_VERSION=4.5.1
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then \
        GODOT_ARCH="linux.arm64"; \
    else \
        GODOT_ARCH="linux.x86_64"; \
    fi && \
    wget -q https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_${GODOT_ARCH}.zip \
    && unzip Godot_v${GODOT_VERSION}-stable_${GODOT_ARCH}.zip \
    && mv Godot_v${GODOT_VERSION}-stable_${GODOT_ARCH} /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && rm Godot_v${GODOT_VERSION}-stable_${GODOT_ARCH}.zip

WORKDIR /workspace

CMD ["/bin/bash"]
