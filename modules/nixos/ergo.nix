{ lib, config, ... }:
{
  options = {
    my.services.ergo = {
      enable = lib.mkEnableOption "ergo ircv3 server";
    };
  };

  config = lib.mkIf config.my.services.ergo.enable {
    services.ergochat.enable = true;
    services.ergochat.settings = {
      # the default settings are kinda weird for people who wanna use PASS
      # specifically opt-out always-on account.multiclient
      # see https://github.com/ergochat/ergo/issues/1336 and https://github.com/ergochat/ergo/issues/1319

      network.name = "kingdom";
      server.name = "bastion.";

      webpush.enabled = true;

      # opers.fum.class = "server-admin";
      # opers.fum.password = "$2a$04$6dKvBWnd40FBsGlw3xWtKut4KuX5VDig4irgG9RsB4dbWpjT9L1cK";
    };

    services.caddy.virtualHosts = lib.mkIf config.my.services.tailscale.enable {
      "ergo:80" = {
        extraConfig = ''
          bind tailscale/ergo
          reverse_proxy localhost:6667
        '';
      };
    };
  };
}
