{
  lib,
  config,
  ...
}:
let
  cfg = config.my.fonts;
in
with lib;
{
  # builds on ../common/fonts.nix

  options = {
    my.fonts = {
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
    fonts = {
      enableDefaultPackages = false;

      fontconfig = {
        enable = true;
        localConf = cfg.conf;

        defaultFonts = {
          emoji = cfg.default.emoji;
          sansSerif = cfg.default.sans;
          serif = cfg.default.serif;
          monospace = cfg.default.mono;
        };
      };
    };
  };
}
