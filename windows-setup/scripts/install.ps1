# This script handles the installation process for applications and utilities on a fresh Windows install.

# Import necessary modules
Import-Module ..\src\modules\apps.ps1
Import-Module ..\src\modules\system.ps1
Import-Module ..\src\modules\utils.ps1

# Load the package configuration
$packages = Get-Content ..\src\config\packages.json | ConvertFrom-Json

# Iterate through each package and install
foreach ($package in $packages) {
    Log-Message "Installing $($package.name) version $($package.version)..."
    Install-App -appName $package.name -installCommand $package.installCommand
}

# Configure system settings after installation
Configure-System
Log-Message "Installation process completed."