{
  lib,
  config,
  inputs,
  ...
}:
{
  # ../nixos/nix.nix builds on this by adding nix.gc.dates

  options = {
    my.nix.enable = lib.mkEnableOption "opinionated nix settings";
  };

  config = lib.mkIf config.my.nix.enable {
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "lix-custom-sub-commands"
        ];
        substituters = [
          "https://cache.lix.systems"
          "https://colmena.cachix.org"
          "https://deploy-rs.cachix.org"
        ];
        trusted-public-keys = [
          "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
          "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
          "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
        ];
      };

      optimise.automatic = true;
      gc = {
        automatic = true;
        options = "--delete-older-than 1w";
      };

      # disable channels, nix-shell was complaining: https://github.com/nix-darwin/nix-darwin/issues/145
      channel.enable = false;

      registry = {
        fum.flake = inputs.fum; # my custom registry
        nixpkgs.flake = inputs.nixpkgs;
      };

      extraOptions = ''
        bash-prompt-prefix = (nix:$name)\040
        builders-use-substitutes = true
      '';
    };

    # TODO: home-manager abuse!
    home-manager.users.${config.my.username}.xdg.configFile."nixpkgs/config.nix".text =
      "{ allowUnfree = true; }";
  };
}
