{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  home.packages = with pkgs; [
    mosh
    zed-editor
    aldente
    dbeaver-bin
    aider-chat
    appcleaner
    # tableplus
    # bitwarden-desktop # replaced with app store version
  ];

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  my.username = "fum";
  my.zsh.enable = true;
  my.git.enable = true;
  my.helix.enable = true;
  my.helix.langs = [
    # "rust"
    "nix"
    # "python"
  ];

  home.sessionVariables = {
    # SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
    SSH_AUTH_SOCK = "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
  };
}
