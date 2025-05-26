#!/bin/bash

# This script installs Homebrew and a set of packages for macOS.
# It includes essential tools, development libraries, and applications.

# Check if the script is run as root
if [[ "$EUID" -eq 0 ]]; then
    echo "Please do not run this script as root."
    exit 1
fi

# Set the script to exit immediately on error
set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOGS_DIR="$SCRIPT_DIR/installer_logs"

# Create logs directory if it doesn't exist
mkdir -p "$LOGS_DIR"

# Source logging utilities
source "$(dirname "${BASH_SOURCE[0]}")/logging_utils.sh"

# Colors for styling
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

    # Add custom taps
    echo -e "\n${BOLD}Adding custom taps...${NC}"
    brew tap Clean6/casks https://github.com/Clean6/homebrew-casks &>/dev/null || true
}

# Arrays of packages to install
brew_packages=(
    "aom"
    "aribb24"
    "autoconf"
    "brotli"
    "c-ares"
    "ca-certificates"
    "cairo"
    "certifi"
    "cjson"
    "cocoapods"
    "coreutils"
    "dav1d"
    "ffmpeg"
    "flac"
    "fontconfig"
    "freetype"
    "frei0r"
    "fribidi"
    "fzf"
    "gdbm"
    "gettext"
    "gh"
    "ghostscript"
    "giflib"
    "git"
    "git-lfs"
    "glib"
    "gmp"
    "gnutls"
    "gradle"
    "graphite2"
    "harfbuzz"
    "highway"
    "htop"
    "icu4c@77"
    "imath"
    "jbig2dec"
    "jpeg-turbo"
    "jpeg-xl"
    "jq"
    "lame"
    "leptonica"
    "libarchive"
    "libass"
    "libb2"
    "libbluray"
    "libdeflate"
    "libevent"
    "libidn"
    "libidn2"
    "liblinear"
    "libmicrohttpd"
    "libnghttp2"
    "libogg"
    "libpng"
    "librist"
    "libsamplerate"
    "libsndfile"
    "libsodium"
    "libsoxr"
    "libssh"
    "libssh2"
    "libtasn1"
    "libtiff"
    "libunibreak"
    "libunistring"
    "libuv"
    "libvidstab"
    "libvmaf"
    "libvorbis"
    "libvpx"
    "libx11"
    "libxau"
    "libxcb"
    "libxdmcp"
    "libxext"
    "libxrender"
    "libyaml"
    "little-cms2"
    "lpeg"
    "lua"
    "luajit"
    "luv"
    "lz4"
    "lzo"
    "m4"
    "mas"
    "mbedtls"
    "mpdecimal"
    "mpg123"
    "ncurses"
    "neovim"
    "nettle"
    "ninja"
    "nmap"
    "node"
    "oniguruma"
    "opencore-amr"
    "openexr"
    "openjdk"
    "openjpeg"
    "openssl@3"
    "opus"
    "p11-kit"
    "pandoc"
    "pango"
    "pcre2"
    "pipenv"
    "pipx"
    "pixman"
    "pkgconf"
    "pyenv"
    "python@3.10"
    "python@3.13"
    "rav1e"
    "readline"
    "rename"
    "rlwrap"
    "rubberband"
    "ruby"
    "rustup"
    "sdl2"
    "selenium-server"
    "snappy"
    "speedtest"
    "speex"
    "sqlite"
    "srt"
    "svt-av1"
    "tesseract"
    "theora"
    "tmux"
    "trash"
    "tree"
    "tree-sitter"
    "unbound"
    "unibilium"
    "unzip"
    "utf8proc"
    "webp"
    "wget"
    "x264"
    "x265"
    "xorgproto"
    "xvid"
    "xz"
    "yarn"
    "zeromq"
    "zimg"
    "zsh"
    "zstd"
)

cask_packages=(
    "appcleaner"
    "blackboardsync"
    "cmake"
    "coconutbattery"
    "discord"
    "dotnet-sdk"
    "firefox"
    "ghidra"
    "gimp"
    "mactex"
    "obsidian"
    "powershell"
    "processing"
    "raspberry-pi-imager"
    "spotify"
    "steam"
    "syncthing"
    "temurin"
    "the-unarchiver"
    "visual-studio-code"
    "vlc"
    "utm"
)

# Function to install a package
install_package() {
    local package=$1
    local is_cask=$2
    local package_type="brew"
    [[ "$is_cask" == "true" ]] && package_type="cask"

    # Check if package was previously installed successfully
    if check_previous_install "$package_type" "$package"; then
        echo -e "${GREEN}✓${NC} ${package} was previously installed successfully"
        return 0
    fi

    if [[ "$is_cask" == "true" ]]; then
        if brew list --cask "$package" &>/dev/null; then
            # Check if cask is outdated
            if brew outdated --cask "$package" &>/dev/null; then
                echo -n "Upgrading ${package}..."
                brew upgrade --cask "$package" &>/dev/null && \
                    echo -e "\r${GREEN}✓${NC} Upgraded ${package}  " || \
                    echo -e "\r${RED}✗${NC} Failed to upgrade ${package}  "
                log_success "$package_type" "$package"
            else
                echo -e "${GREEN}✓${NC} ${package} is already up to date"
                log_success "$package_type" "$package"
            fi
            return 0
        fi
        cmd="brew install --cask"
    else
        if brew list "$package" &>/dev/null; then
            # Check if formula is outdated
            if brew outdated "$package" &>/dev/null; then
                echo -n "Upgrading ${package}..."
                brew upgrade "$package" &>/dev/null && \
                    echo -e "\r${GREEN}✓${NC} Upgraded ${package}  " || \
                    echo -e "\r${RED}✗${NC} Failed to upgrade ${package}  "
                log_success "$package_type" "$package"
            else
                echo -e "${GREEN}✓${NC} ${package} is already up to date"
                log_success "$package_type" "$package"
            fi
            return 0
        fi
        cmd="brew install"
    fi

    echo -n "Installing ${package}..."
    $cmd "$package" &>/dev/null &
    local pid=$!
    spinner $pid
    wait $pid
    if [ $? -eq 0 ]; then
        echo -e "\r${GREEN}✓${NC} Successfully installed ${package}  "
        log_success "$package_type" "$package"
    else
        echo -e "\r${RED}✗${NC} Failed to install ${package}  "
    fi
}

# Main installation process
main() {
    # Install Homebrew if needed
    install_homebrew

    # Update Homebrew
    echo -e "\n${BOLD}Updating Homebrew...${NC}"
    brew update &>/dev/null
    brew upgrade &>/dev/null
    brew cleanup &>/dev/null

    # Add custom taps
    echo -e "\n${BOLD}Adding custom taps...${NC}"
    brew tap Clean6/casks https://github.com/Clean6/homebrew-casks &>/dev/null || true

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
}

# Run main function if script is being executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
