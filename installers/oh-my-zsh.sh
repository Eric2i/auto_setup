#!/usr/bin/env bash
# installers/oh-my-zsh.sh - Install oh-my-zsh with zsh-autosuggestions plugin without sudo

set -e

PREFIX="[auto_setup]"

# Check if oh-my-zsh is already installed
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "$PREFIX oh-my-zsh is already installed"
    
    # Check if zsh-autosuggestions is already installed
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        echo "$PREFIX zsh-autosuggestions plugin is already installed"
        exit 0
    fi
fi

# First, ensure zsh is available
if ! command -v zsh &> /dev/null; then
    echo "$PREFIX ERROR: zsh is not installed. Please install zsh first."
    exit 1
fi

echo "$PREFIX Installing oh-my-zsh..."

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "$PREFIX Downloading oh-my-zsh installer..."
    TEMP_INSTALLER=$(mktemp)
    
    if ! curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$TEMP_INSTALLER"; then
        echo "$PREFIX ERROR: Failed to download oh-my-zsh installer"
        rm -f "$TEMP_INSTALLER"
        exit 1
    fi
    
    # Run the installer in unattended mode (no prompts, no shell change)
    echo "$PREFIX Running oh-my-zsh installer..."
    RUNZSH=no CHSH=no sh "$TEMP_INSTALLER"
    rm -f "$TEMP_INSTALLER"
    
    echo "$PREFIX oh-my-zsh installed successfully to ~/.oh-my-zsh"
else
    echo "$PREFIX oh-my-zsh directory already exists"
fi

# Install zsh-autosuggestions plugin
echo "$PREFIX Installing zsh-autosuggestions plugin..."
PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

if [ ! -d "$PLUGIN_DIR" ]; then
    if ! git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR"; then
        echo "$PREFIX ERROR: Failed to clone zsh-autosuggestions"
        exit 1
    fi
    echo "$PREFIX zsh-autosuggestions plugin installed successfully"
else
    echo "$PREFIX zsh-autosuggestions plugin directory already exists"
fi

# Configure .zshrc to use oh-my-zsh and the plugin
ZSHRC="$HOME/.zshrc"

echo "$PREFIX Configuring .zshrc..."

# Backup existing .zshrc if it exists and doesn't have oh-my-zsh
if [ -f "$ZSHRC" ] && ! grep -q "oh-my-zsh" "$ZSHRC"; then
    echo "$PREFIX Backing up existing .zshrc to .zshrc.backup"
    cp "$ZSHRC" "$ZSHRC.backup"
fi

# Check if oh-my-zsh is already sourced in .zshrc
if [ -f "$ZSHRC" ] && grep -q "oh-my-zsh.sh" "$ZSHRC"; then
    echo "$PREFIX oh-my-zsh already configured in .zshrc"
    
    # Check if zsh-autosuggestions is in plugins
    if ! grep -q "zsh-autosuggestions" "$ZSHRC"; then
        echo "$PREFIX Adding zsh-autosuggestions to plugins..."
        
        # Try to update the plugins line
        if grep -q "^plugins=(" "$ZSHRC"; then
            # Replace the plugins line to add zsh-autosuggestions
            sed -i.bak 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions)/' "$ZSHRC"
            # Clean up any duplicate spaces
            sed -i 's/plugins=( */plugins=(/' "$ZSHRC"
            sed -i 's/  */ /g' "$ZSHRC"
            echo "$PREFIX zsh-autosuggestions added to plugins"
        else
            echo "$PREFIX WARNING: Could not find plugins line in .zshrc"
        fi
    else
        echo "$PREFIX zsh-autosuggestions already in plugins"
    fi
else
    # Create/recreate .zshrc with oh-my-zsh configuration
    echo "$PREFIX Creating .zshrc with oh-my-zsh configuration..."
    
    cat > "$ZSHRC" << 'ZSHRC_EOF'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="robbyrussell"

# Plugins to load
plugins=(git zsh-autosuggestions)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# User configuration
ZSHRC_EOF

    # Add PATH configuration if not already present
    if ! grep -q '.local/bin' "$ZSHRC"; then
        echo '' >> "$ZSHRC"
        echo '# Added by auto_setup' >> "$ZSHRC"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
    fi
    
    echo "$PREFIX .zshrc configured successfully"
fi

echo "$PREFIX oh-my-zsh and zsh-autosuggestions installation complete!"
echo "$PREFIX To use zsh, run: zsh"
echo "$PREFIX To make zsh your default shell, you would typically run: chsh -s \$(which zsh)"
echo "$PREFIX However, without sudo, you may need to manually start zsh or add it to your login scripts"
