{ lib, config, ... }:

{
  options = {
    my.starship.enable = lib.mkEnableOption "starship with home-manager";
  };

  config = lib.mkIf config.my.starship.enable {
    programs.starship = {
      enable = true;

      settings = {
        add_newline = false;
        command_timeout = 1000;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✖](bold red)";
        };
        hostname = {
          ssh_only = false;
          format = "[$hostname](bold green): ";
        };
        username = {
          show_always = true;
          format = "[$user](bold lavender)[@](bold yellow)";
        };
      };
    };

    programs.zsh.initContent = ''
      ############################## extra starship zsh config ##############################    

      # add a blank line between prompts because starship's add_newline is annoying on first open
      precmd() { precmd() { echo "" } }
      alias clear='precmd() { precmd() { echo "" } } && clear'
      alias reset='precmd() { precmd() { echo "" } } && reset'

      # fake transient for starship
      # https://github.com/romkatv/powerlevel10k/issues/888
      # https://github.com/starship/starship/issues/888#issuecomment-2239111488
      # https://vincent.bernat.ch/en/blog/2021-zsh-transient-prompt
      zle-line-init() {
        [[ $CONTEXT == start ]] || return 0

        # we're in line editing mode
        while true; do
          zle .recursive-edit
          local -i ret=$?

          # exit on EOT
          [[ $ret == 0 && $KEYS == $'\4' ]] || break
          [[ -o ignore_eof ]] || exit 0
        done

        # save prompt and shorten current prompt
        local saved_prompt=$PROMPT
        # local saved_rprompt=$RPROMPT
        PROMPT=$(starship module character --status="$STARSHIP_CMD_STATUS")
        # RPROMPT='''
        zle .reset-prompt
        PROMPT=$saved_prompt
        # RPROMPT=$saved_rprompt

        if (( ret )); then
          zle .send-break # ctrl-c
        else
          zle .accept-line # enter
        fi
        return ret
      }

      zle -N zle-line-init # call this on every line

      ############################ end extra starship zsh config ############################    
    '';
  };
}
