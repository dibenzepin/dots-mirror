{ lib, config, ... }:
{
  options = {
    my.services.postgres = {
      enable = lib.mkEnableOption "postgres with users and automatically-created databases";
      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      extraAuth = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf config.my.services.postgres.enable {
    services.postgresql = {
      enable = true;
      enableTCPIP = true;

      identMap = ''
        # needed by default
        superuser_map postgres postgres

        # let me log in as postgres
        superuser_map ${config.my.username} postgres
      '';

      authentication = lib.mkForce (
        ''
          # let me login as postgres over the socket
          local all all peer map=superuser_map

          # let others log into their own databases over the network
          host sameuser all 127.0.0.1/32 password
          host sameuser all ::1/128 password
        ''
        + lib.join "\n" config.my.services.postgres.extraAuth
      );

      # make a database for every user, using the username as the password
      ensureDatabases = config.my.services.postgres.users;
      ensureUsers = map (n: {
        name = n;
        ensureDBOwnership = true;
        ensureClauses.password = n;
      }) config.my.services.postgres.users;
    };
  };
}
