#!/usr/bin/env bash
# installers/zsh.sh - Ensure zsh is available

set -e

PREFIX="[auto_setup]"

# Check if zsh is already available in PATH or system-wide
if command -v zsh &> /dev/null; then
    ZSH_VERSION_OUTPUT=$(zsh --version 2>&1 | head -n1)
    ZSH_PATH=$(which zsh)
    echo "$PREFIX zsh is already available: $ZSH_PATH"
    echo "$PREFIX $ZSH_VERSION_OUTPUT"
    
    # If zsh is not in ~/.local/bin, create a symlink for consistency
    if [ "$ZSH_PATH" != "$HOME/.local/bin/zsh" ] && [ ! -L "$HOME/.local/bin/zsh" ]; then
        mkdir -p ~/.local/bin
        ln -sf "$ZSH_PATH" ~/.local/bin/zsh
        echo "$PREFIX Created symlink at ~/.local/bin/zsh"
    fi
    exit 0
fi

echo "$PREFIX zsh not found in PATH"
echo "$PREFIX Checking system locations..."

# Check common system locations for zsh
if [ -f /usr/bin/zsh ]; then
    echo "$PREFIX Found zsh at /usr/bin/zsh"
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/zsh ~/.local/bin/zsh
    echo "$PREFIX Created symlink at ~/.local/bin/zsh"
    exit 0
elif [ -f /bin/zsh ]; then
    echo "$PREFIX Found zsh at /bin/zsh"
    mkdir -p ~/.local/bin
    ln -sf /bin/zsh ~/.local/bin/zsh
    echo "$PREFIX Created symlink at ~/.local/bin/zsh"
    exit 0
fi

# If we get here, zsh is not available
echo "$PREFIX ============================================"
echo "$PREFIX WARNING: zsh is not installed on this system"
echo "$PREFIX ============================================"
echo "$PREFIX Without sudo access, installing zsh is complex."
echo "$PREFIX Options:"
echo "$PREFIX   1. Ask your system administrator to install zsh"
echo "$PREFIX   2. Use your system's package manager if available"
echo "$PREFIX   3. Build zsh from source (requires build tools)"
echo "$PREFIX"
echo "$PREFIX On most Linux systems, zsh can be installed with:"
echo "$PREFIX   - Ubuntu/Debian: sudo apt-get install zsh"
echo "$PREFIX   - CentOS/RHEL: sudo yum install zsh"
echo "$PREFIX   - Fedora: sudo dnf install zsh"
echo "$PREFIX ============================================"
exit 1
