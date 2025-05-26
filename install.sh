#!/bin/bash

# Colors for styling
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}Auto_Install Setup Script${NC}"
echo -e "This script will download and run the latest version of Auto_Install"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Git is not installed. Please install git first.${NC}"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo -e "\n${BOLD}Downloading Auto_Install...${NC}"

# Clone the repository
if git clone --depth 1 https://github.com/Clean6/Auto_Install.git "$TEMP_DIR" &> /dev/null; then
    echo -e "${GREEN}✓${NC} Download complete"
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "\n${BOLD}macOS detected...${NC}"
        chmod +x "$TEMP_DIR/MacOS-setup/"*.sh
        # If a script argument is provided, run that script, else run macos_setup.sh
        if [[ -n "$1" ]]; then
            SCRIPT_PATH="$TEMP_DIR/$1"
            if [[ -f "$SCRIPT_PATH" ]]; then
                echo -e "${BOLD}Running $1...${NC}"
                bash "$SCRIPT_PATH"
            else
                echo -e "${RED}Script $1 not found in repo!${NC}"
                rm -rf "$TEMP_DIR"
                exit 1
            fi
        else
            "$TEMP_DIR/MacOS-setup/macos_setup.sh"
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo -e "\n${BOLD}Windows detected, please run the Windows setup manually:${NC}"
        echo "1. Open PowerShell as Administrator"
        echo "2. Navigate to: $TEMP_DIR/windows-setup"
        echo "3. Run: Set-ExecutionPolicy Bypass -Scope Process -Force; .\\src\\main.ps1"
    else
        echo -e "${RED}Unsupported operating system${NC}"
        exit 1
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
else
    echo -e "${RED}Failed to download Auto_Install${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi
