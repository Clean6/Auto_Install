#!/bin/bash

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

# Build and install Ghidra
install_ghidra() {
    echo -e "\n${BOLD}Building Ghidra from source...${NC}"

    # Check if Ghidra was previously installed successfully
    if check_previous_install "github" "ghidra"; then
        echo -e "${GREEN}✓${NC} Ghidra was previously installed successfully"
        return 0
    fi

    # Check if Ghidra is already installed
    if [ -d "/Applications/Ghidra" ]; then
        echo -e "${GREEN}✓${NC} Ghidra is already installed"
        log_success "github" "ghidra"
        return 0
    fi

    # Verify Java installation
    if ! java -version &>/dev/null; then
        echo -e "${RED}✗${NC} Java is not installed. Please install Java first."
        return 1
    fi

    # Set up Java environment
    echo -n "Setting up Java environment..."
    if ! sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk; then
        echo -e "\r${RED}✗${NC} Failed to set up Java symlink"
        return 1
    fi
    
    export JAVA_HOME=$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk/Contents/Home
    export PATH="$JAVA_HOME/bin:$PATH"

    # Verify Java setup
    if ! java -version &>/dev/null; then
        echo -e "\r${RED}✗${NC} Java setup failed"
        return 1
    fi
    echo -e "\r${GREEN}✓${NC} Java environment set up successfully"

    # Create a clean temporary directory
    GHIDRA_TMP_DIR=$(mktemp -d)
    echo -n "Cloning Ghidra repository..."
    if git clone --depth 1 https://github.com/NationalSecurityAgency/ghidra.git "$GHIDRA_TMP_DIR" &>/dev/null; then
        echo -e "\r${GREEN}✓${NC} Successfully cloned Ghidra repository  "
        
        # Change to Ghidra directory
        cd "$GHIDRA_TMP_DIR" || return 1
        
        # Set Gradle options for better performance
        export GRADLE_OPTS="-Dorg.gradle.daemon=true -Dorg.gradle.parallel=true"
        
        # Fetch dependencies
        echo -n "Fetching dependencies (this may take a while)..."
        if ./gradlew --console=plain --init-script gradle/support/fetchDependencies.gradle init &>/dev/null; then
            echo -e "\r${GREEN}✓${NC} Dependencies fetched successfully"
            
            # Build Ghidra
            echo -n "Building Ghidra (this may take several minutes)..."
            if ./gradlew buildGhidra; then
                echo -e "\r${GREEN}✓${NC} Successfully built Ghidra  "
                
                # Install Ghidra
                echo -n "Installing Ghidra..."
                sudo mkdir -p /Applications
                if sudo mv build/dist/ghidra_* /Applications/Ghidra &>/dev/null; then
                    echo -e "\r${GREEN}✓${NC} Successfully installed Ghidra  "
                    log_success "github" "ghidra"
                else
                    echo -e "\r${RED}✗${NC} Failed to install Ghidra  "
                    return 1
                fi
            else
                echo -e "\r${RED}✗${NC} Failed to build Ghidra"
                return 1
            fi
        else
            echo -e "\r${RED}✗${NC} Failed to initialize Ghidra build"
            return 1
        fi
        
        # Return to original directory and cleanup
        cd - >/dev/null
        rm -rf "$GHIDRA_TMP_DIR"
        return 0
    else
        echo -e "\r${RED}✗${NC} Failed to clone Ghidra repository"
        return 1
    fi
}

# Install BlackboardSync
install_blackboardsync() {
    echo -e "\n${BOLD}Installing BlackboardSync...${NC}"

    # Check if BlackboardSync was previously installed successfully
    if check_previous_install "github" "blackboardsync"; then
        echo -e "${GREEN}✓${NC} BlackboardSync was previously installed successfully"
        return 0
    fi

    # Check if BlackboardSync is already installed via pip
    if pip3 show blackboardsync &>/dev/null; then
        echo -e "${GREEN}✓${NC} BlackboardSync is already installed"
        log_success "github" "blackboardsync"
        return 0
    fi

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
            log_success "github" "blackboardsync"
            cd - >/dev/null
            rm -rf /tmp/BlackboardSync
            return 0
        else
            echo -e "\r${RED}✗${NC} Failed to install BlackboardSync  "
            return 1
        fi
    else
        echo -e "\r${RED}✗${NC} Failed to clone BlackboardSync  "
        return 1
    fi
}

# Main function
main() {
    install_ghidra
    install_blackboardsync
}

# Run main function if script is being executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
