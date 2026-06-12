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
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  my.username = "fum";

  programs.zoxide.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  catppuccin.enable = true;
  catppuccin.autoEnable = true;
  catppuccin.flavor = "mocha";

  my = {
    git.enable = true;
    ghostty.enable = true;
    fastfetch.enable = true;
    atuin.enable = true;
    zsh.enable = true;
    spotify.enable = true;
    discord.enable = true;
    zed.enable = true;
    starship.enable = true;
    helix.enable = true;
    dbeaver.enable = true;

    luminovo.enable = true;
  };

  home.packages = with pkgs; [
    mosh
    appcleaner
    iina
    qbittorrent
    yaak
    halloy
    inputs.fum.packages.${pkgs.stdenv.hostPlatform.system}.switcheroo
    inputs.fum.packages.${pkgs.stdenv.hostPlatform.system}.mommy
    inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
  ];

  # ssh stuff, to move to module i guess?
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [
      "~/.orbstack/ssh/config"
      "~/.ssh/luminovo.config"
    ];

    settings = {
      "bastion" = {
        ForwardAgent = true;
        User = "fumnanya";
      };

      "github.com".IdentityFile = "~/.ssh/github.pub";
      "gitlab.com".IdentityFile = "~/.ssh/gitlab.pub";
      "codeberg.org".IdentityFile = "~/.ssh/codeberg.pub";
    };
  };

  home.file = {
    ".ssh/github.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5CZ7h5XdWerGPC2Vk0OLT1DOjgcmsm9eK/bDgndFjZ";
    ".ssh/gitlab.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3dbeCesIctxV7gtXw9tto/90tTlYNnxgFO79rty79I";
    ".ssh/codeberg.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPTUfZcfymABkH/5l+Cw3TIYPkNXNvUU1LD6QXGvkAR";
  };
}
