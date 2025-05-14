#!/bin/bash

# Colors for styling
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check and install Homebrew
install_homebrew() {
    echo -e "${BOLD}Checking for Homebrew installation...${NC}"
    if ! command -v brew &> /dev/null; then
        echo -e "${BOLD}Homebrew is not installed. Installing now...${NC}"
        
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo -e "${BOLD}Configuring Homebrew for Apple Silicon...${NC}"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        if command -v brew &> /dev/null; then
            echo -e "${GREEN}✓${NC} Homebrew installed successfully!"
        else
            echo -e "${RED}✗${NC} Failed to install Homebrew. Please install it manually."
            exit 1
        fi
    else
        echo -e "${GREEN}✓${NC} Homebrew is already installed"
    fi
}

# Function to show a spinner while a process is running
spinner() {
    local pid=$1
    while kill -0 $pid 2>/dev/null; do
        for i in "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"; do
            echo -en "\r$i"
            sleep 0.1
            if ! kill -0 $pid 2>/dev/null; then
                break
            fi
        done
    done
    echo -en "\r"
}

# Arrays of packages to install
brew_packages=(
    # Essential
    "neovim"
    "git"
    "tmux"
    "htop"
    "python@3.11"  # Specify Python version explicitly
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
    "rustup"      # Changed from rustup-init
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

# Function to install a package
install_package() {
    local package=$1
    local is_cask=$2

    if [[ "$is_cask" == "true" ]]; then
        if brew list --cask "$package" &>/dev/null; then
            echo -e "${GREEN}✓${NC} ${package} is already installed"
            return 0
        fi
        cmd="brew install --cask"
    else
        if brew list "$package" &>/dev/null; then
            echo -e "${GREEN}✓${NC} ${package} is already installed"
            return 0
        fi
        cmd="brew install"
    fi

    echo -n "Installing ${package}..."
    $cmd "$package" &>/dev/null &
    local pid=$!
    while kill -0 $pid 2>/dev/null; do
        for i in "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"; do
            echo -en "\r$i Installing ${package}..."
            sleep 0.1
            if ! kill -0 $pid 2>/dev/null; then
                break
            fi
        done
    done
    wait $pid
    if [ $? -eq 0 ]; then
        echo -e "\r${GREEN}✓${NC} Successfully installed ${package}  "
    else
        echo -e "\r${RED}✗${NC} Failed to install ${package}  "
    fi
}

# Install Homebrew if needed
install_homebrew

# Update Homebrew
echo -e "\n${BOLD}Updating Homebrew...${NC}"
brew update &>/dev/null
brew upgrade &>/dev/null
brew cleanup &>/dev/null

# Install brew packages
echo -e "\n${BOLD}Installing brew packages...${NC}"
for package in "${brew_packages[@]}"; do
    install_package "$package" "false"
done

# Install cask packages
echo -e "\n${BOLD}Installing cask packages...${NC}"
for package in "${cask_packages[@]}"; do
    install_package "$package" "true"
done

# Add tap for fonts
echo -e "\n${BOLD}Adding font support...${NC}"
brew tap homebrew/cask-fonts &>/dev/null

echo -e "\n${GREEN}✨ Installation complete! ✨${NC}"
