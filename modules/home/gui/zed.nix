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
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      # we don't need them in here...
      # ...but just so that the gc doesn't think they're unneeded
      extraPackages = with pkgs; [
        nixd
        nil
        nixfmt-rfc-style
      ];

      # currently this is in a weird state, with https://github.com/nix-community/home-manager/issues/6835#issuecomment-2951299487
      # right now i'm just doing this to see how it's like
      # to revert back to the tried and tested mode, check https://codeberg.org/fumnanya/dots/commit/d5f4affd964a95deaceff92f87487608ea3dca3c
      userSettings = {
        ui_font_size = 15;
        buffer_font_size = 14;
        buffer_font_family = "TX-02";

        helix_mode = true;

        terminal.blinking = "on";
        restore_on_startup = "none";

        inlay_hints.enabled = true;
        diagnostics.inline.enabled = true;

        lsp = {
          nixd.binary.path = "${pkgs.nixd}/bin/nixd";
          nil.binary.path = "${pkgs.nil}/bin/nil";
          nil.initialization_options.formatting.command = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];

          # rust-analyzer.initialization_options = {
          #   cargo.targetDir = true;
          #   cargo.allTargets = true;
          # };
        };
      };

      userKeymaps = [
        # tab to cycle through completions: https://github.com/zed-industries/zed/discussions/11474
        {
          context = "Editor && showing_completions";
          bindings = {
            tab = "editor::ContextMenuNext";
            shift-tab = "editor::ContextMenuPrevious";
          };
        }
      ];
    };
  };
}
