{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.zed;
in
{
  options = {
    my.zed = {
      enable = lib.mkEnableOption "zed with extra packages, but not home-manager managed";
      path = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor.enable = true;

    catppuccin.zed.enable = false; # we handle this already
    xdg.configFile."zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink cfg.path;

    # we'd use extraPackages, but then the GUI launcher wouldn't see them
    home.activation.updateZedLSPs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "${cfg.path}" ] && [ -f "${cfg.path}" ]; then
        run ${pkgs.jq}/bin/jq \
          '.lsp.nil.binary.path = "${pkgs.nil}/bin/nil" |
           .lsp.nixd.binary.path = "${pkgs.nixd}/bin/nixd" |
           .lsp.nil.initialization_options.formatting.command = ["${pkgs.nixfmt-rfc-style}/bin/nixfmt"]' \
          "${cfg.path}" > "${cfg.path}.tmp" && \
          run mv "${cfg.path}.tmp" "${cfg.path}"
      fi
    '';
  };
}
