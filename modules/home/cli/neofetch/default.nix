{
  lib,
  pkgs,
  config,
  ...
}:

{

  options = {
    my.neofetch.enable = lib.mkEnableOption "home-manager managed neofetch";
  };

  config = lib.mkIf config.my.neofetch.enable {
    home.packages = [
      pkgs.neofetch
    ];

    xdg.configFile."neofetch/config.conf".source = ./config.conf;
    xdg.configFile."neofetch/img/ascii_art_anime.txt".source = ./ascii_art_anime.txt;
  };
}
