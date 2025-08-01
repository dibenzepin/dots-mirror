{
  pkgs,
  inputs,
  ...
}:

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

  my.username = "fum";

  programs.zoxide.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  my = {
    git.enable = true;
    ghostty.enable = true;
    neofetch.enable = true;
    atuin.enable = true;
    zsh.enable = true;
    starship.enable = true;
    spotify.enable = true;
    discord.enable = true;
    zed.enable = true;

    helix.enable = true;
    helix.langs = [
      "rust"
      "nix"
      "python"
    ];

    luminovo.enable = true;

    # firefox.enable = true;
    # firefox.package = inputs.firefox-nightly.packages.${pkgs.system}.firefox-nightly-bin;
  };

  home.packages = with pkgs; [
    mosh
    aldente
    dbeaver-bin
    appcleaner
    iina
    qbittorrent
    yaak
    inputs.fum.packages.${pkgs.system}.switcheroo
    rquickshare
    # tableplus
    # bitwarden-desktop # replaced with app store version
  ];

  home.sessionVariables = {
    # SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
    SSH_AUTH_SOCK = "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
  };
}
