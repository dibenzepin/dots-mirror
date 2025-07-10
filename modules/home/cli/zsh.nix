{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    my.zsh.enable = lib.mkEnableOption "home-manager managed zsh";
  };

  config = lib.mkIf config.my.zsh.enable {
    home.packages = with pkgs; [
      libnotify # zsh-auto-notify wants
      zsh-completions
    ];

    programs.zsh = {
      enable = true;
      defaultKeymap = "emacs";
      enableCompletion = false; # zsh-autocomplete wants this

      autosuggestion.enable = true;
      syntaxHighlighting = {
        enable = true;
        styles = {
          path = "fg=cyan"; # make paths blue
          path_pathseparator = "fg=cyan";
          precommand = "none"; # stop sudo underline
        };
      };

      plugins = [
        {
          # workaround for https://github.com/marlonrichert/zsh-autocomplete/issues/741
          name = "zsh-autocomplete";
          src = pkgs.fetchFromGitHub {
            owner = "aaronkollasch";
            repo = "zsh-autocomplete";
            rev = "d53d90dd205b3ef66101d4cf8692c8518d4daf61";
            hash = "sha256-kUQ1N/XJqn0y8ZHWWeo3PNoD0G6NZyx30YW9Pf5rAv4=";
          };
        }
        {
          # workaround for https://github.com/MichaelAquilina/zsh-auto-notify/pull/49
          name = "auto-notify";
          src = pkgs.fetchFromGitHub {
            owner = "niraami";
            repo = "zsh-auto-notify";
            rev = "f1b54479d2db1002f8823d1217509b3e29015acd";
            hash = "sha256-17w+I74Cgo9n73gZvVRNO2sWEcbbEH/TnyaIJJxEG8M=";
          };
        }
        {
          # from https://github.com/direnv/direnv/issues/443#issuecomment-2380714786
          name = "zsh-completion-sync";
          src = pkgs.fetchFromGitHub {
            owner = "BronzeDeer";
            repo = "zsh-completion-sync";
            rev = "f6e95baf8cd87d9065516d1fa0bf0cb33b4235f3";
            hash = "sha256-XhZ7l8e2H1+W1oUkDrr8pQVPVbb3+1/wuu7MgXsTs+8=";
          };
        }
      ];

      initContent = ''
        setopt nomatch notify interactivecomments

        bindkey '^[[3~' delete-char

        # https://michaelheap.com/kubectl-alias-autocomplete/
        # i don't need this anymore, but just leaving it in here because why not
        # alias k=kubectl
        # compdef k='kubectl'

        # settings for zsh-auto-notify
        AUTO_NOTIFY_IGNORE+=("hx" "fg")
        AUTO_NOTIFY_URGENCY_ON_ERROR="normal"
        AUTO_NOTIFY_TITLE="\"%command\" completed"
        AUTO_NOTIFY_BODY="Total time: %elapsed seconds, Exit code: %exit_code"

        # this is slow and sad :(
        # but you gotta do what you gotta do for those completions
        reload_autocomplete_and_atuin() {
          source $HOME/.zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
          
          # settings for marlonrichert/zsh-autocomplete
          zstyle ':autocomplete:*complete*:*' insert-unambiguous yes # insert common substring
          zstyle ':completion:*:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**' # use prefix as substring
          bindkey '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete # use tab/shift-tab to cycle completions

          eval "$(${pkgs.atuin}/bin/atuin init zsh)"
        }

        # settings for zsh-completion-sync
        zstyle ':completion-sync:compinit:custom' enabled true
        zstyle ':completion-sync:compinit:custom' command reload_autocomplete_and_atuin
      '';
    };
  };
}
