#!/bin/bash

# Source logging utilities
source "$(dirname "${BASH_SOURCE[0]}")/logging_utils.sh"

# Colors for styling
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

INSTALL_FLAG="$HOME/.macos_setup_complete"

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

check_previous_installation

# Run Homebrew installer
"$(dirname "${BASH_SOURCE[0]}")/homebrew_installer.sh"

# Run App Store installer
"$(dirname "${BASH_SOURCE[0]}")/appstore_installer.sh"

# Add tap for fonts (in case not handled by homebrew_installer.sh)
echo -e "\n${BOLD}Adding font support...${NC}"
brew tap homebrew/cask-fonts &>/dev/null

# Create installation flag file with timestamp and summary
{
    echo "Installation completed on $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Installation logs directory: $LOGS_DIR"
    echo -e "\nInstalled Packages Summary:"
    for type in brew cask mas; do
        if [[ -f "$LOGS_DIR/${type}_installed.log" ]]; then
            echo -e "\n${type^} packages:"
            cat "$LOGS_DIR/${type}_installed.log"
        fi
    done
} > "$INSTALL_FLAG"

echo -e "\n${GREEN}✨ Installation complete! ✨${NC}"
echo -e "Installation logs can be found in: $LOGS_DIR"
echo -e "A summary has been saved to: $INSTALL_FLAG"
