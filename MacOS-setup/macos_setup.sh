#!/bin/bash

# Install Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Setup directories and variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
mkdir -p "${SCRIPT_DIR}/logs"

brew update && brew upgrade

# Remove existing tap if present and add fresh
brew untap clean6/homebrew-casks 2>/dev/null || true
brew tap clean6/homebrew-casks https://github.com/Clean6/homebrew-casks.git

# Install Formulae
if [ -f "${SCRIPT_DIR}/brew-formulae.txt" ]; then
    while IFS= read -r formula || [ -n "$formula" ]; do
        [ -z "$formula" ] && continue
        brew install "$formula" | tee -a "${SCRIPT_DIR}/logs/brew_installed.log"
    done < "${SCRIPT_DIR}/brew-formulae.txt"
fi

# Install Casks
if [ -f "${SCRIPT_DIR}/brew-casks.txt" ]; then
    while IFS= read -r cask || [ -n "$cask" ]; do
        [ -z "$cask" ] && continue
        brew install --cask "$cask" | tee -a "${SCRIPT_DIR}/logs/cask_installed.log"
    done < "${SCRIPT_DIR}/brew-casks.txt"
fi

# Install Applications via mas-cli
if [ -f "${SCRIPT_DIR}/mas_packages.txt" ]; then
    while IFS=' ' read -r id name || [ -n "$id" ]; do
        [ -z "$id" ] && continue
        mas install "$id" | tee -a "${SCRIPT_DIR}/logs/mas_installed.log"
    done < "${SCRIPT_DIR}/mas_packages.txt"
fi

