#!/bin/bash

# Enable error handling
set -e

# Install Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Setup directories and variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
mkdir -p "${SCRIPT_DIR}/logs"

# Create empty log files
touch "${SCRIPT_DIR}/logs/brew_installed.log"
touch "${SCRIPT_DIR}/logs/cask_installed.log"
touch "${SCRIPT_DIR}/logs/mas_installed.log"

# Initialize error log
ERROR_LOG="${SCRIPT_DIR}/logs/error.log"
touch "$ERROR_LOG"

echo "Starting installation at $(date)" | tee -a "$ERROR_LOG"

brew update && brew upgrade

# Fix tap issues and add fresh tap
for tap in clean6/homebrew-casks clean6/clean6; do
    brew untap "$tap" 2>/dev/null || true
done

# Clean up and repair Homebrew
brew cleanup
brew doctor || true
brew tap --repair

# Add our custom tap
if ! brew tap clean6/homebrew-casks https://github.com/Clean6/homebrew-casks.git; then
    echo "Failed to tap clean6/homebrew-casks" | tee -a "$ERROR_LOG"
    exit 1
fi

# Update Homebrew again after adding tap
brew update

# Helper functions
verify_install() {
    local type=$1
    local item=$2
    local log=$3
    
    case $type in
        "formula")
            if ! brew list "$item" &>/dev/null; then
                echo "❌ Formula not installed: $item" | tee -a "$log"
                return 1
            fi
            echo "✅ Formula installed: $item" | tee -a "$log"
            ;;
        "cask")
            if ! brew list --cask "$item" &>/dev/null; then
                echo "❌ Cask not installed: $item" | tee -a "$log"
                return 1
            fi
            echo "✅ Cask installed: $item" | tee -a "$log"
            ;;
        "mas")
            if ! mas list | grep -q "^$item"; then
                echo "❌ App Store app not installed: $item" | tee -a "$log"
                return 1
            fi
            echo "✅ App Store app installed: $item" | tee -a "$log"
            ;;
    esac
    return 0
}

print_summary() {
    local log=$1
    echo "===============================================" | tee -a "$log"
    echo "Installation Summary ($(date))" | tee -a "$log"
    echo "===============================================" | tee -a "$log"
    echo "Successful installations:" | tee -a "$log"
    grep "✅" "$log" | sort -u | tee -a "$log"
    echo "" | tee -a "$log"
    echo "Failed installations:" | tee -a "$log"
    grep "❌" "$log" | sort -u | tee -a "$log"
    echo "===============================================" | tee -a "$log"
}

# Install Formulae
echo "Checking for brew-formulae.txt in ${SCRIPT_DIR}..." | tee -a "$ERROR_LOG"
if [ -f "${SCRIPT_DIR}/brew-formulae.txt" ]; then
    echo "===============================================" | tee -a "${SCRIPT_DIR}/logs/brew_installed.log"
    echo "Installing Homebrew formulae..." | tee -a "${SCRIPT_DIR}/logs/brew_installed.log"
    echo "===============================================" | tee -a "${SCRIPT_DIR}/logs/brew_installed.log"
    
    # Remove comments from formulae list
    grep -v '^//' "${SCRIPT_DIR}/brew-formulae.txt" | while IFS= read -r formula || [ -n "$formula" ]; do
        [ -z "$formula" ] && continue
        [ "${formula:0:1}" = "#" ] && continue
        
        echo "Installing formula: $formula..." | tee -a "${SCRIPT_DIR}/logs/brew_installed.log"
        if brew ls --versions "$formula" > /dev/null; then
            echo "Formula already installed: $formula" | tee -a "${SCRIPT_DIR}/logs/brew_installed.log"
            verify_install "formula" "$formula" "$ERROR_LOG"
            continue
        fi
        
        if ! brew install "$formula" 2>> "$ERROR_LOG"; then
            echo "Failed to install formula: $formula" | tee -a "$ERROR_LOG"
        fi 2>&1 | tee -a "${SCRIPT_DIR}/logs/brew_installed.log"
        verify_install "formula" "$formula" "$ERROR_LOG"
    done
    echo "===============================================" | tee -a "${SCRIPT_DIR}/logs/brew_installed.log"
fi

# Install Casks
if [ -f "${SCRIPT_DIR}/brew-casks.txt" ]; then
    echo "===============================================" | tee -a "${SCRIPT_DIR}/logs/cask_installed.log"
    echo "Installing Homebrew casks..." | tee -a "${SCRIPT_DIR}/logs/cask_installed.log"
    echo "===============================================" | tee -a "${SCRIPT_DIR}/logs/cask_installed.log"
    
    # Remove comments from casks list
    grep -v '^//' "${SCRIPT_DIR}/brew-casks.txt" | while IFS= read -r cask || [ -n "$cask" ]; do
        [ -z "$cask" ] && continue
        [ "${cask:0:1}" = "#" ] && continue
        
        echo "Installing cask: $cask..." | tee -a "${SCRIPT_DIR}/logs/cask_installed.log"
        if brew list --cask "$cask" &>/dev/null; then
            echo "Cask already installed: $cask" | tee -a "${SCRIPT_DIR}/logs/cask_installed.log"
            verify_install "cask" "$cask" "$ERROR_LOG"
            continue
        fi
        
        if ! brew install --cask "$cask" 2>> "$ERROR_LOG"; then
            echo "Failed to install cask: $cask" | tee -a "$ERROR_LOG"
        fi 2>&1 | tee -a "${SCRIPT_DIR}/logs/cask_installed.log"
        verify_install "cask" "$cask" "$ERROR_LOG"
    done
    echo "===============================================" | tee -a "${SCRIPT_DIR}/logs/cask_installed.log"
fi

# Install Applications via mas-cli
if [ -f "${SCRIPT_DIR}/mas_packages.txt" ]; then
    echo "Installing Mac App Store applications..." | tee -a "${SCRIPT_DIR}/logs/mas_installed.log"
    while IFS=' ' read -r id name || [ -n "$id" ]; do
        [ -z "$id" ] && continue
        if ! mas install "$id" 2>> "$ERROR_LOG"; then
            echo "Failed to install app: $id ($name)" | tee -a "$ERROR_LOG"
        fi 2>&1 | tee -a "${SCRIPT_DIR}/logs/mas_installed.log"
        verify_install "mas" "$id" "$ERROR_LOG"
    done < "${SCRIPT_DIR}/mas_packages.txt"
fi

echo "Installation completed at $(date)" | tee -a "$ERROR_LOG"
print_summary "$ERROR_LOG"

