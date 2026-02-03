{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  options = {
    my.spotify = {
      enable = lib.mkEnableOption "home-manager managed, spiced spotify";
    };
  };

  config = lib.mkIf config.my.spotify.enable {
    programs.spicetify =
      let
        # https://wiki.nixos.org/wiki/Spicetify-Nix
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        enable = true;
        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";
      };
  };
}
