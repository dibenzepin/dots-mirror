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

      # currently this is in a weird state, with https://github.com/nix-community/home-manager/issues/6835#issuecomment-2951299487
      # right now i'm just doing this to see how it's like
      # to revert back to the tried and tested mode, check https://codeberg.org/fumnanya/dots/commit/d5f4affd964a95deaceff92f87487608ea3dca3c
      userSettings = {
        ui_font_size = 15;
        buffer_font_size = 14;
        buffer_font_family = "TX-02";

        vim_mode = true;
        vim.default_mode = "helix_normal";

        terminal.blinking = "on";
        restore_on_startup = "none";

        languages.YAML.format_on_save = "off";
        lsp = {
          nixd.binary.path = "${pkgs.nixd}/bin/nixd";
          yaml-language-server.settings.yaml.customTags = [ "!reference sequence" ];
          nil.binary.path = "${pkgs.nil}/bin/nil";
          nil.initialization_options.formatting.command = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
        };
      };
    };
  };
}
