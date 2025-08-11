{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.helix;
in
with lib;
{
  options = {
    my.helix = {
      enable = mkEnableOption "home-manager managed helix";
      langs = mkOption {
        type = types.listOf (
          types.enum [
            "python"
            "rust"
            "nix"
          ]
        );
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      defaultEditor = true;

      settings = rec {
        editor = {
          line-number = "relative";
          cursor-shape.insert = "bar";
          lsp.display-messages = true;
          lsp.display-inlay-hints = true; # looks weird :(
          end-of-line-diagnostics = "hint";
          inline-diagnostics.cursor-line = "warning";
          soft-wrap.enable = true;

          # stolen from evil-helix
          # https://github.com/usagi-flow/evil-helix/blob/1c52cc8a70929de70fa8586f3193f00690aa1c75/helix-view/src/editor.rs#L510
          statusline = {
            left = [
              "mode"
              "spacer"
              "version-control"
              "spacer"
              "spinner"
            ];
            center = [
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
            ];
            right = [
              "workspace-diagnostics"
              "selections"
              "register"
              "position"
              "file-encoding"
              "file-type"
            ];
          };
        };

        keys.normal = {
          # i like shift+x to reduce the selection by one line for when i overshoot
          # https://github.com/helix-editor/helix/discussions/6943#discussioncomment-5787797
          X = [
            "extend_line_up"
            "extend_to_line_bounds"
          ];
          A-x = "extend_to_line_bounds";
        }
        # the usual darwin niceties
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          Cmd-s = ":write";

          # ghostty intercepts these by default so disabling...
          # Cmd-a = "select_all";
          # Cmd-c = "yank_to_clipboard";
          # Cmd-v = "replace_selections_with_clipboard";
          # Cmd-z = "undo";
          # Cmd-Z = "redo";
        };

        # the same
        keys.select = keys.normal;

        # git gud
        keys.insert = {
          up = "no_op";
          down = "no_op";
          left = "no_op";
          right = "no_op";
        };
      };

      extraPackages =
        with pkgs;
        lib.optionals (elem "python" cfg.langs) [
          ruff
          basedpyright
        ]
        ++ lib.optionals (elem "nix" cfg.langs) [
          nil
          nixd
          nixfmt-rfc-style
        ];

      languages = {
        language-server = {
          rust-analyzer.config.check.command = mkIf (elem "rust" cfg.langs) "clippy";
          basedpyright.config.basedpyright.analysis.typeCheckingMode =
            mkIf (elem "python" cfg.langs) "strict";
        };

        language =
          lib.optional (elem "nix" cfg.langs) {
            name = "nix";
            auto-format = true;
            language-servers = [
              "nil"
              "nixd"
            ];
            formatter.command = "nixfmt";
          }

          ++ lib.optional (elem "python" cfg.langs) {
            name = "python";
            auto-format = true;
            language-servers = [
              "basedpyright"
              "ruff"
            ];
          };
      };
    };
  };
}
