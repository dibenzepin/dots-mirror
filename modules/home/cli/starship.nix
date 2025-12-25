{ lib, config, ... }:
let
  cfg = config.my.starship;
in
with lib;
{
  options = {
    my.starship = {
      enable = mkEnableOption "starship with home-manager";

      # by default, assume catppuccin is also loaded and use its colours
      hostColour = mkOption {
        type = types.str;
        default = "green";
      };
      userColour = mkOption {
        type = types.str;
        default = "lavender";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableTransience = true;

      settings = {
        command_timeout = 1000;
        # it appears only kitty has "correct behaviour"
        # nix_shell.symbol = "❄️ "; # there's two spaces after by default
        scala.symbol = " "; # default is ugly
        nodejs.symbol = " "; # default is unreadable
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✖](bold red)";
        };
        hostname = {
          ssh_only = false;
          format = "[$hostname](bold ${cfg.hostColour}): ";
        };
        username = {
          show_always = true;
          format = "[$user](bold ${cfg.userColour})[@](bold yellow)";
        };
      };
    };

    programs.fish.functions = {
      starship_transient_prompt_func = "starship module character";
    };
  };
}
