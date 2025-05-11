# This script manages the uninstallation of applications based on the configuration.
# It reads the list of installed applications and removes them accordingly.

# Import the necessary modules
Import-Module ..\src\modules\apps.ps1
Import-Module ..\src\modules\system.ps1

# Function to uninstall an application
function Uninstall-App {
    param (
        [string]$appName
    )
    
    # Logic to uninstall the application
    Write-Host "Uninstalling $appName..."
    # Here you would add the actual uninstall command for the application
}

# Read the list of applications to uninstall from packages.json
$packages = Get-Content ..\src\config\packages.json | ConvertFrom-Json

foreach ($package in $packages) {
    Uninstall-App -appName $package.name
}