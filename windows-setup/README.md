# README.md

# Windows Setup Project

This project provides a PowerShell-based solution for installing applications and utilities on a fresh install of Windows. It automates the installation process by utilizing modular scripts for better organization and maintainability.

## Project Structure

- **src/main.ps1**: Entry point of the script that orchestrates the installation.
- **src/modules/**: Contains modules for different functionalities:
  - **apps.ps1**: Functions for installing applications.
  - **system.ps1**: Functions for system configurations.
  - **utils.ps1**: Utility functions for logging and other tasks.
- **src/config/packages.json**: Configuration file listing applications and utilities to be installed.
- **tests/test.ps1**: Test scripts to verify functionality.
- **scripts/**: Contains installation and uninstallation scripts:
  - **install.ps1**: Handles the installation process.
  - **uninstall.ps1**: Manages the uninstallation of applications.
- **LICENSE**: Licensing information for the project.

## Setup Instructions

1. Clone the repository to your local machine.
2. Open PowerShell as an administrator.
3. Navigate to the project directory.
4. Run `src/main.ps1` to start the installation process.

## Usage Guidelines

- Modify `src/config/packages.json` to add or remove applications as needed.
- Use `scripts/uninstall.ps1` to remove applications that were installed.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.