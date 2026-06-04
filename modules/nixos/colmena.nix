{ lib, config, ... }:
let
  cfg = config.my.colmena;
in
{
  options = {
    my.colmena = {
      enable = lib.mkEnableOption "colmena, for deployments";
      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = {
      colmena = {
        group = "users";
        useDefaultShell = true;
        isSystemUser = true;
        openssh.authorizedKeys.keys = cfg.authorizedKeys;
      };
    };

    security.sudo = {
      extraRules = [
        {
          users = [ "colmena" ];
          commands = [
            {
              command = "/run/current-system/sw/bin/nix-store --no-gc-warning --realise /nix/store/*";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/nix-env --profile /nix/var/nix/profiles/system --set /nix/store/*";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/nix/store/*/bin/switch-to-configuration *";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };
}
