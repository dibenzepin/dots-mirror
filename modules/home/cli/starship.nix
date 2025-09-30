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

      settings = {
        add_newline = false;
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
          format = "[$user](bold #b4befe)[@](bold yellow)"; # normally bold lavender, but that comes from catppuccin.starship, which is disabled on bastion
        };
      };
    };

    programs.zsh.initContent = ''
      ############################## extra starship zsh config ##############################

      # add a blank line between prompts because starship's add_newline is annoying on first open
      precmd() { precmd() { echo "" } }
      alias clear='precmd() { precmd() { echo "" } } && clear'
      alias reset='precmd() { precmd() { echo "" } } && reset'

      ############################ end extra starship zsh config ############################
    '';
  };
}
