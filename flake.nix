{
  description = "starter nixos config flake";

  inputs = {
    # https://github.com/tgirlcloud/lix-diff/issues/1
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    systems.url = "github:nix-systems/default";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    colmena.url = "github:zhaofengli/colmena";
    mac-app-util.url = "github:hraban/mac-app-util/link-contents"; # TODO: check this branch
    treefmt-nix.url = "github:numtide/treefmt-nix";

    lix.url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
    lix.flake = false;

    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
    lix-module.inputs.lix.follows = "lix";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";

    fum.url = "git+https://codeberg.org/fumnanya/flakes";
    fum.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    distro-grub-themes.inputs.nixpkgs.follows = "nixpkgs";
    distro-grub-themes.inputs.flake-utils.follows = "flake-utils";

    firefox-nightly.url = "github:nix-community/flake-firefox-nightly";
    firefox-nightly.inputs.nixpkgs.follows = "nixpkgs";
    firefox-nightly.inputs.lib-aggregate.inputs.flake-utils.follows = "flake-utils";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.inputs.systems.follows = "systems";

    ghostty-shaders.url = "github:sahaj-b/ghostty-cursor-shaders";
    ghostty-shaders.flake = false;

    # homebrew casks
    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    homebrew-kde.url = "github:KDE/homebrew-kde";
    homebrew-kde.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      catppuccin,
      treefmt-nix,
      systems,
      distro-grub-themes,
      nixos-hardware,
      lix-module,
      spicetify-nix,
      nix-darwin,
      mac-app-util,
      nix-homebrew,
      colmena,
      ...
    }@inputs:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtConfig = import ./treefmt.nix;
    in
    {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmt-nix.lib.mkWrapper pkgs treefmtConfig);

      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = (treefmt-nix.lib.evalModule pkgs treefmtConfig).config.build.check self;
      });

      darwinConfigurations.lumi = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/lumi/configuration.nix

          lix-module.darwinModules.default
          mac-app-util.darwinModules.default

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
              catppuccin.homeModules.catppuccin
              spicetify-nix.homeManagerModules.spicetify
            ];
            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.fum = ./hosts/lumi/home.nix;
          }

          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "fum";

              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = inputs.homebrew-core;
                "homebrew/homebrew-cask" = inputs.homebrew-cask;
                "KDE/homebrew-kde" = inputs.homebrew-kde;
              };

              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
        ];
      };

      nixosConfigurations.antikythera = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/antikythera/configuration.nix

          distro-grub-themes.nixosModules."x86_64-linux".default
          nixos-hardware.nixosModules.lenovo-thinkpad-t480s
          lix-module.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [
              catppuccin.homeModules.catppuccin
              spicetify-nix.homeManagerModules.spicetify
            ];
            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.fumnanya = ./hosts/antikythera/home.nix;
          }
        ];
      };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = import nixpkgs { system = "x86_64-linux"; };

          specialArgs = {
            inherit nixpkgs inputs;
          };
        };

        bastion = {
          deployment = {
            targetHost = "bastion";
            targetUser = "colmena";
            # targetHost = "192.168.1.149";
            # targetUser = "root";
            buildOnTarget = true;
          };

          imports = [
            ./hosts/bastion/configuration.nix

            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                catppuccin.homeModules.catppuccin
                spicetify-nix.homeManagerModules.spicetify
              ];
              home-manager.extraSpecialArgs = { inherit nixpkgs inputs; };

              home-manager.users.fumnanya = ./hosts/bastion/home.nix;
            }
          ];
        };
      };
    };
}
