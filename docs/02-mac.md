# mac

got a shiny macbook and want to manage it declaratively?

1.  Install the prerequisites:
    -  [Lix](https://lix.systems/install/) ([Determinate Nix](https://lix.systems/install/) would also work, but this is a Lix household),
    -  the Xcode command-line tools and Rosetta:
       ```sh
       $ xcode-select --install
       $ softwareupdate --install-rosetta`
       ```
1.  Get this repo and link it into `/etc/nix/nix-darwin`:
    ```sh
    $ sudo ln -s ~/dots /etc/nix-darwin
    ```
1.  Switch into a config:
    ```sh
    $ sudo nix run nix-darwin/master#darwin-rebuild -- switch
    ```
1.  Once that's done you might want to give notification access to Script Editor by running the following command to trigger a prompt:
    ```sh
    $ osascript -e 'display notification "World" with title "Hello"'
    ```
