{
  lib,
  pkgs,
  config,
  ...
}:

{
  options = {
    my.git.enable = lib.mkEnableOption "home-manager managed git";
  };

  config = lib.mkIf config.my.git.enable {
    home.packages = [
      pkgs.jujutsu
    ];

    # delta pulls bat in and it complains about Catppuccin not being available
    # so we add it to our config so the theme gets written
    programs.bat.enable = true;

    programs.git = {
      enable = true;
      userName = "fumnanya";
      userEmail = "fmowete@outlook.com";
      aliases = {
        sw = "switch";
        st = "status";
        br = "branch";
        ci = "commit";
      };
      delta.enable = true;
      delta.options = {
        line-numbers = true;
      };
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiGSjQcRY0rXoi9dRT4dZygGo8vjB/NYJXrAhnZ46NX";
        format = "ssh";
      };
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        commit.gpgsign = true;
        url = {
          "ssh://git@github.com/" = {
            insteadOf = [
              "https://github.com/"
              "gh:"
            ];
          };
          "ssh://git@gitlab.com/" = {
            insteadOf = [
              "https://gitlab.com/"
              "gl:"
            ];
          };
          "ssh://git@codeberg.org/" = {
            insteadOf = [
              "https://codeberg.org/"
              "co:"
            ];
          };
        };

        # gotten from https://blog.gitbutler.com/how-git-core-devs-configure-git/
        column.ui = "auto";
        branch.sort = "-committerdate";
        tag.sort = "version:refname";
        diff.algorithm = "histogram";
        diff.colorMoved = "plain";
        diff.renames = true;
        push.followTags = true;
        help.autocorrect = "prompt";
        commit.verbose = true;
        rerere.enabled = true;
        rerere.autoupdate = true;
        merge.conflictstyle = "zdiff3";
      };
    };
  };
}
