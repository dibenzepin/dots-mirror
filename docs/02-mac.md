# mac

got a shiny macbook and want to manage it declaratively?

1.  Install the prerequisites:
    -  [Lix](https://lix.systems/install/) ([Determinate Nix](https://lix.systems/install/) would also work, but this is a Lix household),
    -  the Xcode command-line tools and Rosetta:
       ```sh
       $ xcode-select --install
       $ softwareupdate --install-rosetta
       ```
1.  Get this repo and link it into `/etc/nix/nix-darwin`:
    ```sh
    $ sudo ln -s ~/dots /etc/nix-darwin
    ```
1.  Make sure your computer's name is set correctly:
    ```sh
    $ scutil --set LocalHostName name
    $ scutil --set ComputerName name
    ```
1.  Switch into a config:
    ```sh
    $ sudo nix run nix-darwin/master#darwin-rebuild -- switch
    ```
1. You also want to:
    - Give your terminals (Terminal.app, Ghostty, Zed) the Full Disk Access and Developer Tools permissions
    - Give notification access to Script Editor by running the following command to trigger a prompt:
      ```sh
      $ osascript -e 'display notification "World" with title "Hello"'
      ```
    - Log into atuin and sync your history
    - Set your Lock Screen and Screen Saver settings (3/5 minute display off, immediately require password, 2 minute screensaver)
    - You might need to look at https://github.com/zen-browser/desktop/issues/1510 to get Bitwarden to work with Touch ID
