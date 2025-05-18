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
        ];
        substituters = [ "https://cache.lix.systems" ];
        trusted-public-keys = [
          "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
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
      '';
    };
  };
}
