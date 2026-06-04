{ lib, config, ... }:
let
  cfg = config.my.services.qbittorrent;
in
{
  options = {
    my.services.qbittorrent = {
      enable = lib.mkEnableOption "qbittorrent";
      savePath = lib.mkOption {
        type = lib.types.str;
        default = "/media/torrents";
      };
      whiteListIPs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.qbittorrent = {
      enable = true;
      group = "media";
      openFirewall = true;
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session = {
          DefaultSavePath = cfg.savePath;
          QueueingSystemEnabled = false;
          FinishedTorrentExportDirectory = "${cfg.savePath}/files";
        };
        Preferences = {
          # https://wiki.archlinux.org/title/QBittorrent#Allow_access_without_username_&_password
          WebUI = {
            AuthSubnetWhitelistEnabled = true;
            AuthSubnetWhitelist = lib.join ", " cfg.whiteListIPs;
            UseUPnP = false;
            LocalHostAuth = false;
          };
          General.StatusbarExternalIPDisplayed = true;
        };
      };
    };

    systemd.services.qbittorrent.serviceConfig.UMask = "0002"; # default is 022, but i want to give write perms to :media

    services.caddy.virtualHosts = lib.mkIf config.my.services.tailscale.enable {
      "qbittorrent:80" = {
        extraConfig = ''
          bind tailscale/qbittorrent
          reverse_proxy localhost:8080
        '';
      };
    };
  };
}
