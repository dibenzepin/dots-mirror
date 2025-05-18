{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    my.helix.enable = lib.mkEnableOption "helix";
  };

  config = lib.mkIf config.my.helix.enable {
    environment = {
      systemPackages = [ pkgs.helix ];

      sessionVariables.EDITOR = "hx";
      sessionVariables.VISUAL = "hx";
    };
  };
}
