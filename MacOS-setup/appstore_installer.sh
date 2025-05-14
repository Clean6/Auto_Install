#!/bin/bash

# Colors for styling
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Array of Mac App Store apps with their IDs
mas_packages=(
    "497799835 Xcode"
    "462058435 Microsoft Excel"
    "462054704 Microsoft Word"
    "462062816 Microsoft PowerPoint"
    "985367838 Microsoft Outlook"
    "905953485 NordVPN"
)

# Install Mac App Store applications
install_mas_apps() {
    echo -e "\n${BOLD}Installing Mac App Store applications...${NC}"
    
    # Check if mas is installed
    if ! command -v mas &>/dev/null; then
        echo -e "${RED}Error: mas CLI is not installed. Please install it via Homebrew first.${NC}"
        return 1
    }

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
}

# Main function
main() {
    install_mas_apps
}

# Run main function if script is being executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
