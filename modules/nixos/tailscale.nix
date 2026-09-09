{
  lib,
  config,
  ...
}:
{
  options = {
    my.services.tailscale = {
      enable = lib.mkEnableOption "tailscale + caddy + dns for exposing things on the tailnet";
      hostIP = lib.mkOption {
        type = lib.types.str;
      };
      programs = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
    };
  };

  config = lib.mkIf config.my.services.tailscale.enable {
    services.tailscale.enable = true;
    services.tailscale.useRoutingFeatures = "both";
    services.tailscale.extraSetFlags = [
      "--ssh"
      "--advertise-exit-node"
      "--operator=${config.my.username}" # doesn't work: https://github.com/tailscale/tailscale/issues/18294
    ];

    # make everything point to host in /etc/hosts
    # can (should?) be replaced with https://man.archlinux.org/man/systemd.rr.5.en when nixos gets v261
    networking.hosts = {
      ${config.my.services.tailscale.hostIP} =
        map (p: "${p}.tailscale") (lib.attrNames config.my.services.tailscale.programs)
        ++ lib.attrNames config.my.services.tailscale.programs;
    };

    # listen for dns requests over tailscale
    services.resolved.settings.Resolve = {
      Domains = [ "tailscale" ];
      DNSStubListenerExtra = "${config.my.services.tailscale.hostIP}";
    };

    # generate caddy entries
    services.caddy = {
      enable = true;
      logFormat = "level INFO";

      virtualHosts = lib.mapAttrs' (
        k: v:
        lib.nameValuePair "http://${k} http://${k}.tailscale" {
          extraConfig = ''
            reverse_proxy :${v}
          '';
        }
      ) config.my.services.tailscale.programs;
    };
  };
}
