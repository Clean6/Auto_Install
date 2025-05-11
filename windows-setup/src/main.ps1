# This is the entry point of the PowerShell script.
# It orchestrates the installation of applications and utilities by calling functions from the modules.

# Importing necessary modules
Import-Module -Name "$PSScriptRoot\modules\apps.ps1"
Import-Module -Name "$PSScriptRoot\modules\system.ps1"
Import-Module -Name "$PSScriptRoot\modules\utils.ps1"

# Ensure WinGet is available
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "WinGet is not installed. Please install it from the Microsoft Store."
    exit 1
}

# Check for administrative privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as Administrator"
    exit 1
}

# Function to start the installation process
function Start-Installation {
    # Load the package configuration
    $packages = Get-Content -Raw -Path "$PSScriptRoot\config\packages.json" | ConvertFrom-Json

    # Log the start of the installation
    Log-Message "Starting installation of applications..."

    # Iterate through each package and install
    foreach ($package in $packages) {
        Log-Message "Installing $($package.name) version $($package.version)..."
        Install-App -AppName $package.name -InstallCommand $package.installCommand
    }

    # Configure system settings after installation
    Configure-System

    Log-Message "Installation completed."
}

# Start the installation process
Start-Installation

Write-Host "Installation complete!"