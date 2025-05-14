To run mac os:

-- Make file executable --

	chmod +x Homebrew_Package_Installer.sh
 -- Run Script --
 
	./Homebrew_Package_Installer.sh


To Uninstall all Homebrew items run ```brew list --formula | xargs brew uninstall --force``` and for casks run ```brew list --cask | xargs brew uninstall --force```
