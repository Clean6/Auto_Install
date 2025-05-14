#!/bin/bash

# Colors for styling
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Installation flag file
INSTALL_FLAG="$HOME/.macos_setup_complete"

# Function to check if full installation was previously completed
check_previous_installation() {
    if [ -f "$INSTALL_FLAG" ]; then
        echo -e "${GREEN}✓${NC} Previous installation detected."
        read -p "Would you like to run the installation again? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation skipped. Remove $INSTALL_FLAG to force installation."
            exit 0
        fi
    fi
}

# Run installation check
check_previous_installation

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
    "git-lfs"     # Git Large File Storage
    "tmux"
    "htop"
    "python3"
    "node"        # Node.js runtime
    "mas"         # Mac App Store CLI
    "wget"        # File downloader
    # CLI Tools
    "trash"
    "tree"
    "rename"
    "fzf"
    "jq"
    "rlwrap"
    "nmap"        # Network exploration tool
    "speedtest-cli"  # Internet speed test
    # Development
    "coreutils"
    "ninja"
    "cocoapods"
    "openjdk"
    "rustup"      # Changed from rustup-init
    "gh"
    "gradle"      # Required for building Ghidra
    "unzip"       # Required for Ghidra build process
    "yarn"        # Node.js package manager
    "autoconf"    # Automatic configure script builder
    # Document Processing
    "pandoc"      # Universal document converter
    "ghostscript" # PostScript and PDF interpreter
    # Audio/Video
    "ffmpeg"
)

cask_packages=(
    # Development
    "visual-studio-code"
    "cmake"
    "processing"
    "dotnet-sdk"
    # Utilities
    "appcleaner"
    "the-unarchiver"
    "coconutbattery"
    "raspberry-pi-imager"
    # Cloud & Internet
    "firefox"
    "discord"
    "steam"
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

# Build Ghidra from source
echo -e "\n${BOLD}Building Ghidra from source...${NC}"

# Install required dependencies
REQUIRED_DEPS=("openjdk" "gradle" "git" "unzip")
echo "Installing required dependencies..."
for dep in "${REQUIRED_DEPS[@]}"; do
    echo -n "Checking ${dep}..."
    if ! brew list "$dep" &>/dev/null; then
        echo -e "\r${BOLD}Installing ${dep}...${NC}"
        if brew install "$dep" &>/dev/null; then
            echo -e "\r${GREEN}✓${NC} Successfully installed ${dep}  "
        else
            echo -e "\r${RED}✗${NC} Failed to install ${dep}  "
            exit 1
        fi
    else
        echo -e "\r${GREEN}✓${NC} ${dep} is already installed  "
    fi
done

# Set up Java environment
echo -n "Setting up Java environment..."
sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
export JAVA_HOME=$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# Verify Java installation
if ! java -version &>/dev/null; then
    echo -e "\r${RED}✗${NC} Java setup failed. Please install Java manually."
    exit 1
else
    echo -e "\r${GREEN}✓${NC} Java environment set up successfully  "

# Create a clean temporary directory
GHIDRA_TMP_DIR=$(mktemp -d)
echo -n "Cloning Ghidra repository..."

# Clone with progress (not in background for reliability)
echo -n "Cloning Ghidra repository..."
if git clone --depth 1 https://github.com/NationalSecurityAgency/ghidra.git "$GHIDRA_TMP_DIR" &>/dev/null; then
    echo -e "\r${GREEN}✓${NC} Successfully cloned Ghidra repository  "
    
    # Change to Ghidra directory
    cd "$GHIDRA_TMP_DIR" || exit 1
    
    # Export JAVA_HOME for Gradle
    export JAVA_HOME=$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk/Contents/Home
    
    # Set Gradle options for better performance
    export GRADLE_OPTS="-Dorg.gradle.daemon=true -Dorg.gradle.parallel=true"
    
    # First fetch dependencies
    echo -n "Fetching dependencies (this may take a while)..."
    if ./gradlew --console=plain --init-script gradle/support/fetchDependencies.gradle init &>/dev/null; then
        echo -e "\r${GREEN}✓${NC} Dependencies fetched successfully"
        
        # Then build Ghidra
        echo -n "Building Ghidra (this may take several minutes)..."
        if ./gradlew buildGhidra; then
            echo -e "\r${GREEN}✓${NC} Successfully built Ghidra  "
            
            echo -n "Installing Ghidra..."
            # Create Applications directory if it doesn't exist
            sudo mkdir -p /Applications
            
            # Move built Ghidra to Applications (not in background)
            if sudo mv build/dist/ghidra_* /Applications/Ghidra &>/dev/null; then
                echo -e "\r${GREEN}✓${NC} Successfully installed Ghidra  "
            else
                echo -e "\r${RED}✗${NC} Failed to install Ghidra  "
            fi
        else
            echo -e "\r${RED}✗${NC} Failed to build Ghidra. Try building manually with: cd $GHIDRA_TMP_DIR && ./gradlew buildGhidra"
        fi
    else
        echo -e "\r${RED}✗${NC} Failed to initialize Ghidra build. Check Java installation and internet connection."
    fi
    
    # Return to original directory and cleanup
    cd - >/dev/null
    rm -rf "$GHIDRA_TMP_DIR"
else
    echo -e "\r${RED}✗${NC} Failed to clone Ghidra repository. Check your internet connection."
fi

# Install cask packages
echo -e "\n${BOLD}Installing cask packages...${NC}"
for package in "${cask_packages[@]}"; do
    install_package "$package" "true"
done

# Install Mac App Store applications
echo -e "\n${BOLD}Installing Mac App Store applications...${NC}"

# Array of Mac App Store apps with their IDs
mas_packages=(
    "497799835 Xcode"
    "462058435 Microsoft Excel"
    "462054704 Microsoft Word"
    "462062816 Microsoft PowerPoint"
    "985367838 Microsoft Outlook"
    "905953485 NordVPN"
)

# Install each Mac App Store package
for package in "${mas_packages[@]}"; do
    id=${package%% *}
    name=${package#* }
    echo -n "Installing ${name}..."
    if mas install "$id" &>/dev/null; then
        echo -e "\r${GREEN}✓${NC} Successfully installed ${name}  "
        
        # Accept Xcode license if this was Xcode
        if [ "$id" = "497799835" ] && command -v xcodebuild >/dev/null 2>&1; then
            echo -n "Accepting Xcode license..."
            if sudo xcodebuild -license accept &>/dev/null; then
                echo -e "\r${GREEN}✓${NC} Xcode license accepted  "
            fi
        fi
    else
        echo -e "\r${RED}✗${NC} Failed to install ${name}. You may need to install it manually from the Mac App Store.  "
    fi
done

# Add tap for fonts
echo -e "\n${BOLD}Adding font support...${NC}"
brew tap homebrew/cask-fonts &>/dev/null

# Install BlackboardSync
echo -e "\n${BOLD}Installing BlackboardSync...${NC}"
echo -n "Cloning BlackboardSync repository..."
git clone https://github.com/sanjacob/BlackboardSync /tmp/BlackboardSync &>/dev/null &
pid=$!
spinner $pid
wait $pid

if [ $? -eq 0 ]; then
    echo -e "\r${GREEN}✓${NC} Successfully cloned BlackboardSync  "
    echo -n "Installing BlackboardSync..."
    cd /tmp/BlackboardSync
    pip3 install . &>/dev/null &
    pid=$!
    spinner $pid
    wait $pid
    if [ $? -eq 0 ]; then
        echo -e "\r${GREEN}✓${NC} Successfully installed BlackboardSync  "
        # Cleanup
        cd - >/dev/null
        rm -rf /tmp/BlackboardSync
    else
        echo -e "\r${RED}✗${NC} Failed to install BlackboardSync  "
    fi
else
    echo -e "\r${RED}✗${NC} Failed to clone BlackboardSync  "
fi

# Create installation flag file
touch "$INSTALL_FLAG"
echo "$(date)" > "$INSTALL_FLAG"

echo -e "\n${GREEN}✨ Installation complete! ✨${NC}"
