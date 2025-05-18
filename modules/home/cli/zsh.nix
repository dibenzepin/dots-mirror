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

      # TODO: replace with a more nix-y way?
      zplug = {
        enable = true;
        plugins = [
          {
            name = "aaronkollasch/zsh-autocomplete"; # workaround for https://github.com/marlonrichert/zsh-autocomplete/issues/741
            tags = [ "at:d53d90dd205b3ef66101d4cf8692c8518d4daf61" ];
          }
          {
            name = "niraami/zsh-auto-notify"; # workaround for https://github.com/MichaelAquilina/zsh-auto-notify/pull/49
            tags = [ "at:f1b54479d2db1002f8823d1217509b3e29015acd" ];
          }
        ];
      };

      initContent = ''
        setopt nomatch notify interactivecomments

        # settings for marlonrichert/zsh-autocomplete
        zstyle ':autocomplete:*complete*:*' insert-unambiguous yes # insert common substring
        zstyle ':completion:*:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**' # use prefix as substring
        bindkey '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete # use tab/shift-tab to cycle completions

        # settings for zsh-auto-notify
        AUTO_NOTIFY_IGNORE+=("hx" "fg")
        AUTO_NOTIFY_URGENCY_ON_ERROR="normal"
        AUTO_NOTIFY_TITLE="\"%command\" completed"
        AUTO_NOTIFY_BODY="Total time: %elapsed seconds, Exit code: %exit_code"
      '';
    };
  };
}
