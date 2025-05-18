{ lib, config, ... }:
{
  # builds on top of ../common/nix.nix

  config = lib.mkIf config.my.nix.enable {
    nix.gc = {
      dates = "weekly";
    };
  };
}
