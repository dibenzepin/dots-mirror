{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    my.services.redis = {
      enable = lib.mkEnableOption "redis (but like, valkey actually)";
    };
  };

  config = lib.mkIf config.my.services.redis.enable {
    services.redis.package = pkgs.valkey;

    services.redis.servers."".enable = true;
    services.redis.servers."".bind = null; # listen on all interfaces
    services.redis.servers."".requirePass = "valkeyisawesomeactually";
  };
}
