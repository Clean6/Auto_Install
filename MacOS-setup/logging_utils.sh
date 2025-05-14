#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOGS_DIR="$SCRIPT_DIR/installer_logs"

# Create logs directory if it doesn't exist
mkdir -p "$LOGS_DIR"

# Function to log a successful installation
log_success() {
    local package_type=$1  # brew, cask, mas, github
    local package_name=$2
    local log_file="$LOGS_DIR/${package_type}_installed.log"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $package_name" >> "$log_file"
}

# Function to check if a package was previously installed
check_previous_install() {
    local package_type=$1  # brew, cask, mas, github
    local package_name=$2
    local log_file="$LOGS_DIR/${package_type}_installed.log"
    
    if [[ -f "$log_file" ]]; then
        if grep -q "$package_name" "$log_file"; then
            return 0  # Found in log
        fi
    fi
    return 1  # Not found in log
}
