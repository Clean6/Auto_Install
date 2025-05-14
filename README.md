To run mac os:

-- Install Homebrew --

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

-- Run Script --

	./Homebrew_Package_Installer.sh


To Uninstall all Homebrew items run ```brew list --formula | xargs brew uninstall --force``` and for casks run ```brew list --cask | xargs brew uninstall --force```
