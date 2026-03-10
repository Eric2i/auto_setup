#!/usr/bin/env bash
# installers/uv.sh - Install uv (Python package manager) without sudo

set -e

PREFIX="[auto_setup]"

# Check if uv is already installed and working
if command -v uv &> /dev/null; then
    echo "$PREFIX uv is already installed ($(uv --version))"
    exit 0
fi

echo "$PREFIX Installing uv..."

# Ensure ~/.local/bin exists
mkdir -p ~/.local/bin

# Download uv binary from GitHub releases
echo "$PREFIX Downloading uv binary from GitHub..."
TEMP_DIR=$(mktemp -d)
if ! curl -fsSL https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-unknown-linux-gnu.tar.gz -o "$TEMP_DIR/uv.tar.gz"; then
    echo "$PREFIX ERROR: Failed to download uv"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Extract the binary
echo "$PREFIX Extracting uv..."
tar -xzf "$TEMP_DIR/uv.tar.gz" -C "$TEMP_DIR"

# Move binary to ~/.local/bin
if [ -f "$TEMP_DIR/uv-x86_64-unknown-linux-gnu/uv" ]; then
    mv "$TEMP_DIR/uv-x86_64-unknown-linux-gnu/uv" ~/.local/bin/uv
    chmod +x ~/.local/bin/uv
elif [ -f "$TEMP_DIR/uv" ]; then
    mv "$TEMP_DIR/uv" ~/.local/bin/uv
    chmod +x ~/.local/bin/uv
else
    echo "$PREFIX ERROR: uv binary not found in archive"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Clean up
rm -rf "$TEMP_DIR"

echo "$PREFIX uv installed successfully to ~/.local/bin/uv"

# Verify installation
if ~/.local/bin/uv --version &> /dev/null; then
    echo "$PREFIX uv version: $(~/.local/bin/uv --version)"
else
    echo "$PREFIX Warning: uv installed but may not be working correctly"
fi
