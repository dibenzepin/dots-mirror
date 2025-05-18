{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  # https://wiki.nixos.org/wiki/Spicetify-Nix
  spice = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  options = {
    my.spotify = {
      enable = lib.mkEnableOption "home-manager managed, spiced spotify";
    };
  };

  config = lib.mkIf config.my.spotify.enable {
    programs.spicetify = {
      enable = true;
      theme = spice.themes.catppuccin;
      colorScheme = "mocha";
    };
  };
}
