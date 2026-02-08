# Auto Server Wizard 🧙‍♂️

> Quickly set up a new Linux server for ML research **without sudo**

Auto Server Wizard is a modular bootstrap script that automatically installs common development tools into user-local directories (like `~/.local/bin`). Perfect for setting up remote servers, cloud instances, or any Linux environment where you don't have root access.

## Quick Start

Run this one-liner on any new Linux server:

```bash
curl -fsSL https://raw.githubusercontent.com/Eric2i/auto_server_wizard/main/setup.sh | bash
```

That's it! The script will:
- Create `~/.local/bin` if it doesn't exist
- Add `~/.local/bin` to your PATH (in `~/.bashrc` and `~/.zshrc`)
- Install all configured software tools user-locally

After running, restart your shell or run:
```bash
source ~/.bashrc  # or source ~/.zshrc if using zsh
```

## Currently Supported Software

- **Neovim** - Modern Vim-based text editor (installed via AppImage)
- **uv** - Fast Python package manager (installed from GitHub releases)
- **zsh** - Z Shell (detects system installation or provides guidance)
- **oh-my-zsh** - Framework for managing zsh configuration with plugins
  - Includes **zsh-autosuggestions** plugin for command suggestions

## Features

- ✅ **No sudo required** - Everything installs to user-local directories
- ✅ **Idempotent** - Safe to run multiple times, won't reinstall existing tools
- ✅ **Modular** - Each tool has its own installer script
- ✅ **Clear output** - Status messages with `[auto_server_wizard]` prefix
- ✅ **One-liner install** - Works from a fresh `curl | bash`

## Architecture

The project uses a modular structure:

```
.
├── README.md              # This file
├── setup.sh               # Main orchestrator script
└── installers/
    ├── neovim.sh          # Neovim installer module
    ├── uv.sh              # uv installer module
    ├── zsh.sh             # zsh installer module
    └── oh-my-zsh.sh       # oh-my-zsh + plugins installer module
```

### How It Works

1. **`setup.sh`** (main orchestrator):
   - Ensures `~/.local/bin` exists
   - Adds `~/.local/bin` to PATH if needed
   - Downloads and runs each installer module from GitHub
   - Provides clear status messages

2. **`installers/*.sh`** (tool-specific modules):
   - Each tool gets its own installer script
   - Scripts check if the tool is already installed (idempotent)
   - Install to `~/.local/bin` or other user-local paths
   - No sudo required

## Adding New Installer Modules

To add support for a new tool:

1. Create a new script in `installers/` (e.g., `installers/mytool.sh`)
2. Make it executable: `chmod +x installers/mytool.sh`
3. Follow the template:

```bash
#!/usr/bin/env bash
# installers/mytool.sh - Install MyTool without sudo

set -e

PREFIX="[auto_server_wizard]"

# Check if already installed
if command -v mytool &> /dev/null; then
    echo "$PREFIX MyTool is already installed"
    exit 0
fi

echo "$PREFIX Installing MyTool..."

# Install to ~/.local/bin or similar user-local path
mkdir -p ~/.local/bin
# ... installation steps ...

echo "$PREFIX MyTool installed successfully"
```

4. Add the script name to the `INSTALLERS` array in `setup.sh`:

```bash
INSTALLERS=(
    "neovim.sh"
    "mytool.sh"  # Add your new installer here
)
```

## Manual Installation

If you want to run the script manually (without the one-liner):

```bash
# Clone the repository
git clone https://github.com/Eric2i/auto_server_wizard.git
cd auto_server_wizard

# Run the setup script
./setup.sh
```

## Requirements

- Linux (x86_64 architecture)
- `bash`, `curl`, and basic GNU coreutils
- No sudo/root access required

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
