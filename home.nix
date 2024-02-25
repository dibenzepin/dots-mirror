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
    ];

    programs.git = {
        enable = true;
        userName = "poopsicles";
        userEmail = "87488715+poopsicles@users.noreply.github.com";

        extraConfig = {
            init.defaultBranch = "main";
        };
    };
}
