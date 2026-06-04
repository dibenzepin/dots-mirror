{ lib, config, ... }:
{
  options = {
    my.services.sure = {
      enable = lib.mkEnableOption "sure finance";
    };
  };

  config = lib.mkIf config.my.services.sure.enable {
    services.caddy.virtualHosts = lib.mkIf config.my.services.tailscale.enable {
      "sure:80" = {
        extraConfig = ''
          bind tailscale/sure
          reverse_proxy localhost:3000
        '';
      };
    };
  };
}
