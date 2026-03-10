#!/usr/bin/env bash
# installers/neovim.sh - Install Neovim without sudo

set -e

PREFIX="[auto_setup]"

# Set defaults for environment variables if not provided by setup.sh
if [ -z "$LOCAL_CONFIGS_DIR" ]; then
    # When running standalone, try to find the configs directory
    SCRIPT_DIR_LOCAL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    LOCAL_CONFIGS_DIR="${SCRIPT_DIR_LOCAL}/configs"
fi

if [ -z "$GITHUB_RAW_BASE_CONFIGS" ]; then
    GITHUB_RAW_BASE_CONFIGS="https://raw.githubusercontent.com/Eric2i/auto_setup/main/configs"
fi

# ============================================================================
# 1. Install Neovim Binary (if not already installed)
# ============================================================================

# Check if nvim is already installed and working
if command -v nvim &> /dev/null; then
    echo "$PREFIX Neovim is already installed ($(nvim --version | head -n1))"
else
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
fi

# ============================================================================
# 2. Configure Neovim (always run if config doesn't exist yet)
# ============================================================================

NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_CONFIG_FILE="$NVIM_CONFIG_DIR/init.vim"

# Check if config already exists (idempotent)
if [ -f "$NVIM_CONFIG_FILE" ]; then
    echo "$PREFIX Neovim config already exists at $NVIM_CONFIG_FILE, skipping configuration"
else
    echo "$PREFIX Setting up Neovim configuration..."
    
    # Create config directory
    mkdir -p "$NVIM_CONFIG_DIR"
    
    # Determine the source of init.vim (local or remote)
    LOCAL_INIT_VIM="${LOCAL_CONFIGS_DIR}/nvim/init.vim"
    
    if [ -f "$LOCAL_INIT_VIM" ]; then
        # Use local config file (running from clone)
        echo "$PREFIX Copying init.vim from local repo..."
        cp "$LOCAL_INIT_VIM" "$NVIM_CONFIG_FILE"
    else
        # Download config from GitHub (running via curl | bash)
        echo "$PREFIX Downloading init.vim from GitHub..."
        REMOTE_INIT_VIM="${GITHUB_RAW_BASE_CONFIGS}/nvim/init.vim"
        if ! curl -fsSL "$REMOTE_INIT_VIM" -o "$NVIM_CONFIG_FILE"; then
            echo "$PREFIX ERROR: Failed to download init.vim"
            exit 1
        fi
    fi
    
    echo "$PREFIX Neovim config installed to $NVIM_CONFIG_FILE"
fi

# ============================================================================
# 3. Install vim-plug (if not already installed)
# ============================================================================

VIM_PLUG_PATH="$HOME/.local/share/nvim/site/autoload/plug.vim"
VIM_PLUG_NEWLY_INSTALLED=false

if [ -f "$VIM_PLUG_PATH" ]; then
    echo "$PREFIX vim-plug is already installed"
else
    echo "$PREFIX Installing vim-plug..."
    mkdir -p "$(dirname "$VIM_PLUG_PATH")"
    
    if curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -o "$VIM_PLUG_PATH"; then
        echo "$PREFIX vim-plug installed successfully"
        VIM_PLUG_NEWLY_INSTALLED=true
    else
        echo "$PREFIX ERROR: Failed to install vim-plug"
        exit 1
    fi
fi

# ============================================================================
# 4. Auto-install plugins (only if vim-plug was just installed)
# ============================================================================

if [ "$VIM_PLUG_NEWLY_INSTALLED" = true ]; then
    echo "$PREFIX Auto-installing Neovim plugins..."
    
    # Use the nvim binary (either freshly installed or existing)
    NVIM_BIN="nvim"
    if ! command -v nvim &> /dev/null; then
        # If nvim is not in PATH yet, use the full path
        NVIM_BIN="$HOME/.local/bin/nvim"
    fi
    
    if "$NVIM_BIN" --headless +PlugInstall +qall; then
        echo "$PREFIX Neovim plugins installed successfully"
    else
        echo "$PREFIX Warning: Plugin installation may have failed or completed with warnings"
    fi
else
    echo "$PREFIX Skipping plugin installation (vim-plug was already present)"
fi

echo "$PREFIX Neovim setup complete!"
