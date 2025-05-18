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
  # ../nixos/fonts.nix builds on this by adding fonts.fontconfig

  options = {
    my.fonts = {
      enable = mkEnableOption "fonts";

      packages = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    fonts.packages = cfg.packages;
  };
}
