# Auto_Install - Multi-Platform Setup Automation

This repository contains setup automation scripts for both macOS and Windows environments. It helps you quickly set up a new machine with all the necessary development tools, applications, and configurations.

## Features

- **macOS Setup**:
  - Automated Homebrew installation and package management
  - Checks for and upgrades outdated packages, skipping those already up to date
  - Development tools (Python, Git, Node.js, etc.)
  - Common applications via Homebrew Cask
  - Mac App Store applications via `mas`
  - Python package installation
  - **Logging**: All installed packages are logged in `MacOS-setup/installer_logs/`
  - **Summary**: A summary of the installation is saved to `~/.macos_setup_complete`

- **Windows Setup**:
  - PowerShell-based automation
  - Microsoft Office installation
  - Common development tools
  - System configuration

## Quick Start

### macOS Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Clean6/Auto_Install.git
   cd Auto_Install/MacOS-setup
   ```

2. Make the script executable:
   ```bash
   chmod +x macos_setup.sh
   ```

3. Run the script:
   ```bash
   ./macos_setup.sh
   ```

### Windows Setup

1. Clone the repository
2. Open PowerShell as Administrator
3. Navigate to the windows-setup directory
4. Run:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\src\main.ps1
   ```

## Customization

### macOS
- Edit `MacOS-setup/homebrew_installer.sh` to modify:
  - Homebrew packages (`brew_packages` array)
  - Cask applications (`cask_packages` array)
- Edit `MacOS-setup/appstore_installer.sh` to modify:
  - Mac App Store applications (`mas_packages` array)
- **Logs**: Check `MacOS-setup/installer_logs/` for logs of installed packages.
- **Summary**: See `~/.macos_setup_complete` for a summary of the last installation.

### Windows
- Edit `windows-setup/src/config/packages.json` to modify the Windows package list

## Uninstallation

### macOS
To remove all Homebrew packages:
```bash
# Remove formulae
brew list --formula | xargs brew uninstall --force

# Remove casks
brew list --cask | xargs brew uninstall --force

# Clean up Homebrew
brew cleanup
```

### Windows
Run the uninstallation script:
```powershell
.\windows-setup\scripts\uninstall.ps1
```

## Requirements

### macOS
- macOS 10.15 or later
- Administrative privileges
- Internet connection
- Apple ID (for Mac App Store installations)

### Windows
- Windows 10 or later
- Administrative privileges
- Internet connection
- PowerShell 5.1 or later

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
