{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

{
  options = {
    my.ghostty.enable = lib.mkEnableOption "home-manager managed ghostty (except on macos where it's bring-your-own-ghostty)";
  };

  config =
    let
      shaders = [
        "cursor_warp"
        "rectangle_boom_cursor"
      ];
    in
    lib.mkIf config.my.ghostty.enable {
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
        settings = {
          font-family = "FiraCode Nerd Font Mono";
          working-directory = "home";
          window-save-state = "never";
          font-thicken = true;
          background-opacity = 0.95;
          window-padding-x = 15;
          window-padding-y = 10;
          macos-option-as-alt = true;
          macos-titlebar-style = "tabs";
          auto-update = "off";
          shell-integration-features = true;
          keybind = [ ''shift+enter=text:\n'' ];
          custom-shader-animation = "always";
          custom-shader = map (s: "shaders/${s}.glsl") shaders;
        };
      };

      xdg.configFile = builtins.listToAttrs (
        map (s: {
          name = "ghostty/shaders/${s}.glsl";
          value = {
            source = "${inputs.ghostty-shaders}/${s}.glsl";
          };
        }) shaders
      );
    };
}
