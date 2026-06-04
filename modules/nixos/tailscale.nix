{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    my.services.tailscale = {
      enable = lib.mkEnableOption "tailscale + caddy for exposing things on the tailnet";
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

    services.caddy = {
      enable = true;
      logFormat = "level INFO";

      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/tailscale/caddy-tailscale@v0.0.0-20260106222316-bb080c4414ac" ];
        hash = "sha256-iUQXsmUJEdOpv6uXte73RXFOhxfzwb/r9vdCTVXjP4Y=";
      };
    };
  };
}
