#!/bin/bash

# Colors and symbols for styling
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Spinner array
spinner=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" )

# Arrays of packages to install
brew_packages=(
    # Essential
    "neovim"
    "git"
    "tmux"
    "htop"
    "python3"
    # CLI Tools
    "trash"
    "tree"
    "rename"
    "fzf"
    "jq"
    "rlwrap"
    # Development
    "coreutils"
    "ninja"
    "cocoapods"
    "openjdk"
    "rustup-init"
    "gh"
    "winetricks"
    # Audio/Video
    "ffmpeg"
    "pdfpc"
)

cask_packages=(
    # Development
    "visual-studio-code"
    "cmake"
    "processing"
    "dotnet-sdk"
    "ghidra"
    # Utilities
    "bettertouchtool"
    "appcleaner"
    "the-unarchiver"
    "coconutbattery"
    "raspberry-pi-imager"
    # Cloud & Internet
    "firefox"
    "discord"
    # Productivity
    "mactex"
    # Audio/Video/Graphics
    "vlc"
    "spotify"
)

# Enhanced progress bar function
show_progress() {
    local duration=$1
    local prefix=$2
    local width=30
    local progress=0
    local bar_char="━"
    local empty_char="─"
    local spin_idx=0

    printf "\n"
    while [ $progress -le 100 ]; do
        local count=$(($width * $progress / 100))
        local spaces=$(($width - count))
        
        # Create the filled and empty portions of the bar
        local fill=""
        local empty=""
        for ((i=0; i<count; i++)); do
            fill="${fill}${bar_char}"
        done
        for ((i=0; i<spaces; i++)); do
            empty="${empty}${empty_char}"
        done

        # Print the progress bar with spinner
        printf "\r${BLUE}${spinner[$spin_idx]}${NC} ${prefix} ${BOLD}[${GREEN}${fill}${NC}${BOLD}${empty}]${NC} ${BOLD}%d%%${NC}" $progress

        progress=$((progress + 2))
        spin_idx=$(( (spin_idx + 1) % 10 ))
        sleep $duration
    done
    printf "\n"
}

# Function to update and upgrade Homebrew
update_homebrew() {
    echo "Updating Homebrew..."
    brew update >/dev/null 2>&1 & show_progress 0.1 "Updating Homebrew"
    echo "Upgrading existing packages..."
    brew upgrade >/dev/null 2>&1 & show_progress 0.1 "Upgrading packages"
    echo "Cleaning up..."
    brew cleanup >/dev/null 2>&1 & show_progress 0.1 "Cleaning up"
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update and upgrade Homebrew packages
update_homebrew

# Install brew packages
echo "Installing brew packages..."
for package in "${brew_packages[@]}"; do
    if brew list "$package" &>/dev/null; then
        echo "✓ ${package} is already installed"
    else
        echo "Installing ${package}..."
        brew install "$package" >/dev/null 2>&1 & show_progress 0.05 "Installing ${package}"
        echo "✓ ${package} installed successfully"
    fi
done

# Install cask packages
echo "Installing cask packages..."
for package in "${cask_packages[@]}"; do
    if brew list --cask "$package" &>/dev/null; then
        echo "✓ ${package} is already installed"
    else
        echo "Installing ${package}..."
        brew install --cask "$package" >/dev/null 2>&1 & show_progress 0.1 "Installing ${package}"
        echo "✓ ${package} installed successfully"
    fi
done

# Add tap for fonts
echo "Adding font support..."
brew tap homebrew/cask-fonts >/dev/null 2>&1 & show_progress 0.05

echo "✨ Installation complete! ✨"