{ lib, config, ... }:
{
  options = {
    my.services.jellyfin = {
      enable = lib.mkEnableOption "jellyfin";
    };
  };

  config = lib.mkIf config.my.services.jellyfin.enable {
    services.jellyfin.enable = true;
    services.jellyfin.openFirewall = true;
    services.jellyfin.group = "media";

    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];

    services.caddy.virtualHosts = lib.mkIf config.my.services.tailscale.enable {
      "jellyfin:80" = {
        extraConfig = ''
          bind tailscale/jellyfin
          reverse_proxy localhost:8096
        '';
      };
    };
  };
}
