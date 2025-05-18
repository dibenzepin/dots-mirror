{ lib, config, ... }:
{
  options = {
    my.zsh.enable = lib.mkEnableOption "zsh";
  };

  config = lib.mkIf config.my.zsh.enable {
    programs.zsh.enable = true;

    # home-manager programs.zsh.enableCompletion says so
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enableCompletion
    environment.pathsToLink = [ "/share/zsh" ];
  };
}
