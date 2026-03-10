#!/usr/bin/env bash
# setup.sh - Auto Setup main orchestrator
# This script sets up a new Linux server without sudo by installing software user-locally

set -e

PREFIX="[auto_setup]"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_INSTALLERS_DIR="${SCRIPT_DIR}/installers"
LOCAL_CONFIGS_DIR="${SCRIPT_DIR}/configs"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/Eric2i/auto_setup/main/installers"
GITHUB_RAW_BASE_CONFIGS="https://raw.githubusercontent.com/Eric2i/auto_setup/main/configs"

echo "$PREFIX Starting Auto Setup..."
echo ""

# Ensure ~/.local/bin exists
echo "$PREFIX Ensuring ~/.local/bin exists..."
mkdir -p ~/.local/bin

# Add ~/.local/bin to PATH if not already present
add_to_path() {
    local shell_config=$1
    if [ -f "$shell_config" ]; then
        if ! grep -q '\$HOME/.local/bin' "$shell_config"; then
            echo "$PREFIX Adding ~/.local/bin to PATH in $shell_config"
            echo '' >> "$shell_config"
            echo '# Added by auto_setup' >> "$shell_config"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_config"
        else
            echo "$PREFIX ~/.local/bin already in PATH ($shell_config)"
        fi
    else
        echo "$PREFIX Creating $shell_config and adding PATH..."
        echo '# Added by auto_setup' > "$shell_config"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_config"
    fi
}

# Update PATH in both bashrc and zshrc
add_to_path ~/.bashrc
add_to_path ~/.zshrc

# Export PATH for current session
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "$PREFIX Installing software..."
echo ""

# List of installers to run
INSTALLERS=(
    "neovim.sh"
    "uv.sh"
    "zsh.sh"
    "oh-my-zsh.sh"
)

# Run each installer (use local files if available, otherwise download from GitHub)
for installer in "${INSTALLERS[@]}"; do
    echo "$PREFIX Running installer: $installer"

    # Export variables for use by installer scripts
    export SCRIPT_DIR
    export LOCAL_CONFIGS_DIR
    export GITHUB_RAW_BASE_CONFIGS

    # Check if running from a local clone with installers/ directory
    if [ -f "${LOCAL_INSTALLERS_DIR}/${installer}" ]; then
        # Use local installer
        echo "$PREFIX Using local installer: ${LOCAL_INSTALLERS_DIR}/${installer}"
        chmod +x "${LOCAL_INSTALLERS_DIR}/${installer}"
        bash "${LOCAL_INSTALLERS_DIR}/${installer}"
    else
        # Download installer from GitHub
        TEMP_INSTALLER=$(mktemp)
        if curl -fsSL "${GITHUB_RAW_BASE}/${installer}" -o "$TEMP_INSTALLER"; then
            chmod +x "$TEMP_INSTALLER"
            bash "$TEMP_INSTALLER"
            rm -f "$TEMP_INSTALLER"
        else
            echo "$PREFIX ERROR: Failed to download $installer"
            rm -f "$TEMP_INSTALLER"
            exit 1
        fi
    fi

    echo ""
done

echo "$PREFIX Setup complete!"
echo "$PREFIX Please restart your shell or run: source ~/.bashrc"
echo "$PREFIX (or source ~/.zshrc if using zsh)"
