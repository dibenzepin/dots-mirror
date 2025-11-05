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
        git.push-new-bookmarks = true;
        signing = {
          backend = "ssh";
          behavior = "own";
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGPBbDGOYi1I65IKGnD1R2SYF83FDRZSAblkvI0AKY2";
        };

        # stolen from https://radicle.xyz/2025/08/14/jujutsu-with-radicle
        aliases = {
          tug = [
            "bookmark"
            "move"
            "--from"
            "closest_bookmark(@)"
            "--to"
            "closest_pushable(@)"
          ];
        };
        revset-aliases = {
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
          "closest_pushable(to)" =
            "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
        };
        git.write-change-id-header = true;
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
            description = "The current jj status";
            when = "jj --ignore-working-copy root";
            shell = [
              "sh"
              "--norc"
              "--noprofile"
            ];
            symbol = "🥋 ";
            command = ''
              jj log --revisions @ --no-graph --color always --limit 1 --template '
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

    programs.delta.enable = true;
    programs.delta.options.line-numbers = true;
    programs.delta.enableGitIntegration = true;

    programs.git = {
      enable = true;
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILj80AhtIADDRd2rz66ejlDD4P80I5p9zpxNwcqFsOhz";
        format = "ssh";
      };
      settings = {
        user.name = "fumnanya";
        user.email = "fmowete@outlook.com";
        alias = {
          sw = "switch";
          st = "status";
          br = "branch";
          ci = "commit";
        };

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
