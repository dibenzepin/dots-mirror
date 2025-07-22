{
  lib,
  config,
  ...
}:

{
  options = {
    my.git.enable = lib.mkEnableOption "home-manager managed git and jujutsu";
  };

  config = lib.mkIf config.my.git.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user.name = "fumnanya";
        user.email = "fmowete@outlook.com";
        ui.paginate = "never";
        # templates.git_push_bookmark = ''"fumnanya/push-" ++ change_id.short()'';
        signing = {
          backend = "ssh";
          behavior = "own";
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGPBbDGOYi1I65IKGnD1R2SYF83FDRZSAblkvI0AKY2";
        };
      };
    };

    # from https://github.com/jj-vcs/jj/wiki/Starship
    programs.starship.settings = {
      git_branch.disabled = true;
      git_commit.disabled = true;
      git_state.disabled = true;
      git_metrics.disabled = true;
      git_status.disabled = true;

      custom =
        lib.listToAttrs (
          map
            (module: {
              name = module;
              value = {
                when = true;
                command = "jj root >/dev/null 2>&1 || starship module ${module}";
                description = "Only show ${module} if we're not in a jj repo";
              };
            })
            [
              "git_branch"
              "git_commit"
              "git_state"
              "git_metrics"
              "git_status"
            ]
        )
        // {
          jj = {
            ignore_timeout = true;
            description = "The current jj status";
            detect_folders = [ ".jj" ];
            symbol = "🥋 ";
            command = ''
              jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
                separate(" ",
                  change_id.shortest(4),
                  bookmarks,
                  "|",
                  concat(
                    if(conflict, "💥"),
                    if(divergent, "🚧"),
                    if(hidden, "👻"),
                    if(immutable, "🔒"),
                  ),
                  raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
                  raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                    truncate_end(29, description.first_line(), "…"),
                    "(no description set)",
                  ) ++ raw_escape_sequence("\x1b[0m"),
                )
              '
            '';
          };
        };
    };

    # delta pulls in bat
    # bat complains about not seeing catppuccin mocha
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
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILj80AhtIADDRd2rz66ejlDD4P80I5p9zpxNwcqFsOhz";
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
