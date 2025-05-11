# This module contains functions for installing various applications.

function Install-App {
    param (
        [string]$AppName
    )

    switch ($AppName) {
        "Google Chrome" {
            Start-Process "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -ArgumentList "/silent /install" -Wait
            Log-Message "Google Chrome installed successfully."
        }
        "Visual Studio Code" {
            Start-Process "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -ArgumentList "/silent" -Wait
            Log-Message "Visual Studio Code installed successfully."
        }
        "7-Zip" {
            Start-Process "https://www.7-zip.org/a/7z1900-x64.exe" -ArgumentList "/S" -Wait
            Log-Message "7-Zip installed successfully."
        }
        default {
            Log-Message "Application '$AppName' is not recognized for installation."
        }
    }
}

function Install-WinGetPackages {
    param (
        [array]$Packages
    )

    foreach ($package in $Packages) {
        Write-Host "Installing $package..."
        winget install --id $package --accept-package-agreements --accept-source-agreements -h
    }
}

function Install-CustomPackage {
    param (
        [string]$Name,
        [string]$Url,
        [string]$SilentArgs,
        [string]$InstallerPath
    )

    $tempPath = Join-Path $env:TEMP "$Name-installer.exe"

    if ($Url) {
        Write-Host "Downloading $Name..."
        Invoke-WebRequest -Uri $Url -OutFile $tempPath
        $installerPath = $tempPath
    }
    else {
        $installerPath = $InstallerPath
    }

    Write-Host "Installing $Name..."
    Start-Process -FilePath $installerPath -ArgumentList $SilentArgs -Wait -NoNewWindow

    if ($tempPath -and (Test-Path $tempPath)) {
        Remove-Item $tempPath -Force
    }
}

function Install-MicrosoftOffice {
    param (
        [string]$SetupPath,
        [string]$ConfigPath
    )

    Write-Host "Installing Microsoft Office..."
    
    # Verify setup.exe and config file exist
    if (-not (Test-Path $SetupPath)) {
        Write-Error "Office setup.exe not found at: $SetupPath"
        return $false
    }

    if (-not (Test-Path $ConfigPath)) {
        Write-Error "Office configuration XML not found at: $ConfigPath"
        return $false
    }

    # Log the installation start
    Log-Message "Starting Microsoft Office installation using ODT..."
    
    try {
        # Run the Office Deployment Tool with the configuration
        $process = Start-Process -FilePath $SetupPath -ArgumentList "/configure `"$ConfigPath`"" -Wait -NoNewWindow -PassThru
        
        if ($process.ExitCode -eq 0) {
            Log-Message "Microsoft Office installation completed successfully"
            return $true
        } else {
            Log-Message "Microsoft Office installation failed with exit code: $($process.ExitCode)"
            return $false
        }
    }
    catch {
        Log-Message "Error installing Microsoft Office: $_"
        return $false
    }
}

# Main installation function
function Install-Applications {
    $config = Get-Content (Join-Path $PSScriptRoot "..\config\packages.json") | ConvertFrom-Json

    # Install WinGet packages
    Install-WinGetPackages -Packages $config.winget.packages

    # Install custom packages
    foreach ($app in $config.custom_installers.PSObject.Properties) {
        $appConfig = $app.Value
        Install-CustomPackage -Name $app.Name -Url $appConfig.url -SilentArgs $appConfig.silent_args -InstallerPath $appConfig.installer_path
    }

    # Install Office if configured
    if ($config.custom_installers.office) {
        Install-MicrosoftOffice -SetupPath $config.custom_installers.office.setup_path -ConfigPath $config.custom_installers.office.config_path
    }
}