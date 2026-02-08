#!/usr/bin/env bash
# installers/neovim.sh - Install Neovim without sudo

set -e

PREFIX="[auto_server_wizard]"

# Check if nvim is already installed and working
if command -v nvim &> /dev/null; then
    echo "$PREFIX Neovim is already installed ($(nvim --version | head -n1))"
    exit 0
fi

echo "$PREFIX Installing Neovim..."

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        NVIM_ARCH="x86_64"
        ;;
    aarch64|arm64)
        NVIM_ARCH="arm64"
        ;;
    *)
        echo "$PREFIX ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Ensure ~/.local exists
mkdir -p ~/.local

# Download and extract Neovim tarball
echo "$PREFIX Downloading Neovim for $NVIM_ARCH..."
DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"

if ! curl -fsSL "$DOWNLOAD_URL" | tar xzf - -C ~/.local --strip-components=1; then
    echo "$PREFIX ERROR: Failed to download or extract Neovim"
    exit 1
fi

echo "$PREFIX Neovim installed successfully to ~/.local/bin/nvim"

# Verify installation
if ~/.local/bin/nvim --version &> /dev/null; then
    echo "$PREFIX Neovim version: $(~/.local/bin/nvim --version | head -n1)"
else
    echo "$PREFIX Warning: Neovim installed but may not be working correctly"
fi
