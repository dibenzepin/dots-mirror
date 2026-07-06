{ lib, config, ... }:
{
  options = {
    my.services.jellyfin = {
      enable = lib.mkEnableOption "jellyfin";
    };
  };

  config = lib.mkIf config.my.services.jellyfin.enable {
    my.services.tailscale.programs.jellyfin = "8096";

    services.jellyfin.enable = true;
    services.jellyfin.openFirewall = true;
    services.jellyfin.group = "media";

    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];
  };
}
