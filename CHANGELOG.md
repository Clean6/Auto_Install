# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-05-17
### Added
- Created custom Homebrew tap for additional packages
- Added BlackboardSync as a Homebrew cask
### Changed
- Updated installation process to use BlackboardSync cask instead of direct installation

## [1.2.0] - 2025-05-17
### Changed
- Removed GitHub-based application builds for simpler, more reliable installation
- Updated logging system to remove GitHub installation tracking
- Simplified macOS setup process to focus on package manager and App Store installations

## [1.1.0] - 2025-05-15
### Changed
- Restructured macOS setup scripts into modular components
- Split installation process into separate scripts for Homebrew, App Store, and GitHub builds
- Added installation state tracking to prevent unnecessary reinstallations
- Added NordVPN to Mac App Store installations

## [1.0.1] - 2025-05-14
### Fixed
- Improved handling of Mac App Store installations for newer macOS versions
- Added graceful fallback with manual installation instructions when mas-cli fails
- Added Xcode license acceptance after installation

## [1.0.0] - 2025-05-14
### Added
- Initial release
- macOS setup script with Homebrew package installation
- Windows setup scripts with PowerShell automation
- Automated Ghidra build from source
- Python setuptools installation
- Mac App Store application installation
- BlackboardSync installation
- Support for both Intel and Apple Silicon Macs
- Windows Office installation automation
- Comprehensive documentation

### Changed
- Improved Mac App Store authentication handling
- Enhanced error handling and user feedback
- Organized project structure

### Fixed
- Mac App Store sign-in verification
- Installation progress indicators
- Directory cleanup after installations
