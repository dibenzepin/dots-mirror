{
  lib,
  config,
  ...
}:
{
  options = {
    my.goldwarden.enable = lib.mkEnableOption "goldwarden";
  };

  config = lib.mkIf config.my.goldwarden.enable {
    programs.goldwarden.enable = true;

    environment.sessionVariables = {
      GOLDWARDEN_SYSTEM_AUTH_DISABLED = "true";
    };
  };
}
