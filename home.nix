{ config, pkgs, apple-emoji, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "fumnanya";
  home.homeDirectory = "/home/fumnanya";

  # make home manager work better on non-nixos
  targets.genericLinux.enable = true;

  # make fonts actually work
  fonts.fontconfig.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.neofetch
    pkgs.starship
    pkgs.zoxide
    pkgs.fzf
    pkgs.atuin
    pkgs.typst
    pkgs.rye
    pkgs.jujutsu
    pkgs.delta

    apple-emoji
    pkgs.inter
    (pkgs.nerdfonts.override {
        fonts = ["CodeNewRoman" "FiraCode"];
    })
    
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # stuff to be sourced in .zshrc (. "$HOME/.nix-zshrc")
    ".nix-zshrc".source = ./configs/zshrc;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/fumnanya/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # copy font prefs
  xdg.configFile."fontconfig/fonts.conf".source = ./configs/fonts.conf;

  # neofetch
  xdg.configFile."neofetch/config.conf".source = ./configs/neofetch/config.conf;
  xdg.configFile."neofetch/img/ascii_art_anime.txt".source = ./configs/neofetch/ascii_art_anime.txt;

  # wezterm
  xdg.configFile."wezterm/wezterm.lua".source = ./configs/wezterm.lua;

  # run-or-raise
  xdg.configFile."run-or-raise/shortcuts.conf".source = ./configs/run-or-raise.conf;

  # other prefs
  programs.git = {
        enable = true;
        userName = "fumnanya";
        userEmail = "fmowete@outlook.com";
        aliases = {
          co = "checkout";
          st = "status";
          br = "branch";
          ci = "commit";   
        };
        delta.enable = true;
        delta.options = {
            line-numbers = true;
        };
        extraConfig = {
            init.defaultBranch = "main";
            pull.rebase = true;
            url = {
                "git@github.com:" = {
                insteadOf = "https://github.com/";
                };
            };
        };
    };

    programs.starship = {
        enable = true;

        settings = {
            character = {
                success_symbol = "[➜](bold green)";
                error_symbol = "[✖](bold red)";
            };
            hostname = {
                ssh_only = false;
                format = "[$hostname](bold #71e968): ";
            };
            username = {
                show_always = true;
                format = "[$user](bold #c09bf6)@";
            };
        };  
    };

    programs.atuin = {
        enable = true;
        enableZshIntegration = true;
        settings = {
            dialect = "uk";
            enter_accept = false;
            sync = {
                records = true;
            };
        };
    };
}
