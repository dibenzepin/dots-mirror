{
  lib,
  config,
  ...
}:

{

  options = {
    my.fastfetch.enable = lib.mkEnableOption "home-manager managed fastfetch";
  };

  config = lib.mkIf config.my.fastfetch.enable {
    xdg.configFile."fastfetch/ascii_art_anime.txt".source = ./ascii_art_anime.txt;

    programs.fastfetch = {
      enable = true;
      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

        logo = {
          type = "file";
          source = "${config.xdg.configHome}/fastfetch/ascii_art_anime.txt";
          padding.right = 3;
          color."1" = "bright_white";
        };

        display = {
          separator = "\t ▐ ";
          key.width = 16;
        };

        modules = [
          "break"
          {
            type = "title";
            key = "user";
            keyColor = "magenta";
            format = "{user-name}";
          }
          {
            type = "os";
            key = "os";
            keyColor = "red";
          }
          {
            type = "kernel";
            key = "kernel";
            keyColor = "yellow";
          }
          {
            type = "packages";
            key = "package";
            keyColor = "green";
          }
          {
            type = "shell";
            key = "shell";
            keyColor = "magenta";
          }
          {
            type = "wm";
            key = "wm";
            keyColor = "cyan";
          }
          {
            type = "theme";
            key = "theme";
            keyColor = "yellow";
          }
          {
            type = "terminal";
            key = "terminal";
            keyColor = "magenta";
          }
          {
            type = "cpu";
            key = "cpu";
            keyColor = "red";
          }
          {
            type = "memory";
            key = "memory";
            keyColor = "cyan";
          }
          "break"
          {
            type = "colors";
            paddingLeft = 0;
            symbol = "block";
          }
        ];
      };
    };
  };
}
