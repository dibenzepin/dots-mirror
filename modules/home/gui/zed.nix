{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.zed;
  nixExtensionTools = [
    pkgs.nixd
    pkgs.nil
    pkgs.nixfmt
  ];
in
{
  options = {
    my.zed = {
      enable = lib.mkEnableOption "home-manager managed zed with extra packages (except on macos where it's bring-your-own-zed) ";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      package = if pkgs.stdenv.isDarwin then null else pkgs.zed-editor;
      extensions = [
        "nix"
        "toml"
      ];

      # currently this is in a weird state, with https://github.com/nix-community/home-manager/issues/6835#issuecomment-2951299487
      # right now i'm just doing this to see how it's like
      # to revert back to the tried and tested mode, check https://codeberg.org/fumnanya/dots/commit/d5f4affd964a95deaceff92f87487608ea3dca3c
      userSettings = {
        helix_mode = true;

        ui_font_size = 15;
        buffer_font_size = 14;
        buffer_font_family = "Google Sans Code";
        terminal.blinking = "on";
        terminal.font_family = "Google Sans Code";
        terminal.font_size = 13;

        restore_on_startup = "launchpad";
        auto_update = false;

        inlay_hints.enabled = true;
        diagnostics.inline.enabled = true;

        agent.play_sound_when_agent_done = true;
        show_edit_predictions = false;

        lsp = {
          nixd.binary.path = "${pkgs.nixd}/bin/nixd";
          nil.binary.path = "${pkgs.nil}/bin/nil";
          nil.initialization_options.formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];

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

    # # we don't need them in here...
    # # ...but just so that the gc doesn't think they're unneeded
    # ...on macOS we can't use extraPackages because we're bringing our own, so just add it to the home env
    programs.zed-editor.extraPackages = lib.mkIf (!pkgs.stdenv.isDarwin) nixExtensionTools;
    home.packages = lib.mkIf pkgs.stdenv.isDarwin nixExtensionTools;
  };
}
