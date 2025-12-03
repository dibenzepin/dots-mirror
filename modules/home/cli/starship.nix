{ lib, config, ... }:
let
  cfg = config.my.starship;
in
with lib;
{
  options = {
    my.starship = {
      enable = mkEnableOption "starship with home-manager";
      colour = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableTransience = true;

      settings = {
        command_timeout = 1000;
        nix_shell.symbol = "❄️ "; # there's two spaces after by default
        scala.symbol = " "; # default is ugly
        nodejs.symbol = " "; # default is unreadable
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✖](bold red)";
        };
        hostname = {
          ssh_only = false;
          format = "[$hostname](bold ${cfg.colour}): ";
        };
        username = {
          show_always = true;
          format = "[$user](bold lavender)[@](bold yellow)";
        };
      };
    };

    programs.fish.functions = {
      starship_transient_prompt_func = "starship module character";
    };
  };
}
