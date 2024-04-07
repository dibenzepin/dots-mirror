{pkgs, ...}: {
    home.username = "fumnanya";
    home.homeDirectory = "/home/fumnanya";
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;
    targets.genericLinux.enable = true;

    home.packages = [
        pkgs.neofetch
        pkgs.pyenv
        pkgs.poetry
        pkgs.radicle-cli
        pkgs.starship
        pkgs.zoxide
        pkgs.fzf
        pkgs.atuin
    ];

    programs.git = {
        enable = true;
        userName = "poopsicles";
        userEmail = "87488715+poopsicles@users.noreply.github.com";
        aliases = {
          co = "checkout";
          st = "status";
          br = "branch";
          ci = "commit";   
        };
        extraConfig = {
            init.defaultBranch = "main";
        };
    };

    programs.starship = {
        enable = true;

        settings = {
            character = {
                success_symbol = "[➜](bold green)";
                error_symbol = "[✗](bold red)";
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
