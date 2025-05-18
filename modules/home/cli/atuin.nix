{
  lib,
  config,
  ...
}:

{
  options = {
    my.atuin.enable = lib.mkEnableOption "home-manager managed atuin";
  };

  config = lib.mkIf config.my.atuin.enable {
    programs.atuin = {
      enable = true;
      settings = {
        dialect = "uk";
        inline_height = 0;
        style = "auto";
        enter_accept = false;
        sync = {
          records = true;
        };
      };
    };
  };
}
