{
  lib,
  config,
  inputs,
  ...
}:
{
  options = {
    my.nix.enable = lib.mkEnableOption "home-manager managed opinionated nix settings";
  };

  config = lib.mkIf config.my.nix.enable {
    xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "lix-custom-sub-commands"
        ];
        substituters = [ "https://cache.lix.systems" ];
        trusted-public-keys = [
          "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        ];
      };

      gc = {
        automatic = true;
        frequency = "weekly";
        options = "--delete-older-than 1w";
      };

      # disable channels, nix-shell was complaining: https://github.com/nix-darwin/nix-darwin/issues/145
      # channel.enable = false;

      registry = {
        fum.flake = inputs.fum; # my custom registry
        nixpkgs.flake = inputs.nixpkgs;
      };

      extraOptions = ''
        bash-prompt-prefix = (nix:$name)\040
        auto-optimise-store = true
      '';
    };
  };
}
