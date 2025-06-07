{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.zed;
in
{
  options = {
    my.zed = {
      enable = lib.mkEnableOption "zed with extra packages, but not home-manager managed";
      path = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extraPackages = with pkgs; [
        nil
        nixd
        nixfmt-rfc-style
      ];
    };

    catppuccin.zed.enable = false; # we handle this already
    xdg.configFile."zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink cfg.path;
  };
}
