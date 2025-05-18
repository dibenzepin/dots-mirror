{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.fonts;
in
with lib;
{
  options = {
    my.fonts = {
      enable = mkEnableOption "home-manager managed fonts";

      packages = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };

      default = {
        emoji = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        sans = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        serif = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        mono = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
      };

      conf = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.packages;
    xdg.configFile."fontconfig/fonts.conf".text = mkIf pkgs.stdenv.isLinux cfg.conf;

    fonts.fontconfig = {
      enable = pkgs.stdenv.isLinux;

      defaultFonts = {
        emoji = cfg.default.emoji;
        sansSerif = cfg.default.sans;
        serif = cfg.default.serif;
        monospace = cfg.default.mono;
      };
    };

    # assuming we're probably not installing fonts with HM (aka non-system wide) on NixOS
    targets.genericLinux.enable = pkgs.stdenv.isLinux;

    # # onlyoffice has trouble with symlinks: https://github.com/ONLYOFFICE/DocumentServer/issues/1859
    # system.userActivationScripts = {
    #   copy-fonts-local-share = {
    #     text = ''
    #       rm -rf ~/.local/share/fonts
    #       mkdir -p ~/.local/share/fonts
    #       cp ${pkgs.corefonts}/share/fonts/truetype/* ~/.local/share/fonts/
    #       chmod 544 ~/.local/share/fonts
    #       chmod 444 ~/.local/share/fonts/*
    #     '';
    #   };
    # };
  };
}
