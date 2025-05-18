{
  lib,
  config,
  pkgs,
  ...
}:
let
  uname = config.my.username;
in
with lib;
{
  options = {
    my.username = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = {
    home = {
      username = uname;
      homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${uname}" else "/home/${uname}";
    };
  };
}
