#!/bin/bash

# Install Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update && brew upgrade

# Add custom tap for additional casks
brew tap clean6/homebrew-casks

# Install Formulae
brew install $(cat brew-formulae.txt) | tee logs/brew_installed.log

# Install Casks
brew install --cask $(cat brew-casks.txt) | tee logs/cask_installed.log

# Install Applications via mas-cli
mas install $(cat mas-apps.txt) | tee logs/mas_installed.log

