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

# Ensure ~/.local/bin exists
mkdir -p ~/.local/bin

# Download Neovim AppImage
echo "$PREFIX Downloading Neovim AppImage..."
if ! curl -fsSL -o ~/.local/bin/nvim-linux-x86_64.appimage https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage; then
    echo "$PREFIX ERROR: Failed to download Neovim AppImage"
    exit 1
fi

# Make it executable
chmod +x ~/.local/bin/nvim-linux-x86_64.appimage

# Create symlink
ln -sf ~/.local/bin/nvim-linux-x86_64.appimage ~/.local/bin/nvim

echo "$PREFIX Neovim installed successfully to ~/.local/bin/nvim"

# Verify installation
if ~/.local/bin/nvim --version &> /dev/null; then
    echo "$PREFIX Neovim version: $(~/.local/bin/nvim --version | head -n1)"
else
    echo "$PREFIX Warning: Neovim installed but may not be working correctly"
fi
