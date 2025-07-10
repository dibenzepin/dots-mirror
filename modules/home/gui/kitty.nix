{ lib, config, ... }:

{
  options = {
    my.kitty.enable = lib.mkEnableOption "home-manager managed kitty";
  };

  config = lib.mkIf config.my.kitty.enable {
    home.shellAliases = {
      s = "kitten ssh";
    };

    programs.kitty = {
      enable = true;
      settings = {
        font_family = "FiraCode Nerd Font Mono";
        font_size = 13;
        tab_bar_min_tabs = 1;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
        window_padding_width = 10;
        background_opacity = 0.95;
        cursor_trail = 3;
        scrollback_lines = 10000;
        macos_option_as_alt = "yes";
      };
      # todo: adapt for darwin
      keybindings = {
        "ctrl+," = "edit_config_file";
        "ctrl+shift+enter" = "new_window_with_cwd";
      };
    };
  };
}
