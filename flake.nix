{
  description = "starter nixos config flake";

  inputs = {
    # https://github.com/tgirlcloud/lix-diff/issues/1
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    systems.url = "github:nix-systems/default";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    fum.url = "git+https://codeberg.org/fumnanya/flakes";

    lix.url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
    lix.flake = false;

    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
    lix-module.inputs.lix.follows = "lix";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";
    lix-module.inputs.flake-utils.follows = "flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    distro-grub-themes.inputs.nixpkgs.follows = "nixpkgs";
    distro-grub-themes.inputs.flake-utils.follows = "flake-utils";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    firefox-nightly.url = "github:nix-community/flake-firefox-nightly";
    firefox-nightly.inputs.nixpkgs.follows = "nixpkgs";
    firefox-nightly.inputs.lib-aggregate.inputs.flake-utils.follows = "flake-utils";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.inputs.systems.follows = "systems";

    apple-emoji.url = "github:samuelngs/apple-emoji-linux";
    apple-emoji.inputs.nixpkgs.follows = "nixpkgs";
    apple-emoji.inputs.treefmt-nix.follows = "treefmt-nix";
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

      # antikythera nixos
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
    };
}
