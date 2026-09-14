{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  my.username = "fum";
  system.primaryUser = "fum";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Set sudo to use touch id
  security.pam.services.sudo_local.touchIdAuth = true;

  # nix remote builder for linux, see https://wiki.nixos.org/wiki/NixOS_virtual_machines_on_macOS#linux-builder
  # and https://nixcademy.com/posts/macos-linux-builder/
  # nix.linux-builder.enable = true;
  # nix.linux-builder.ephemeral = true;
  # nix.linux-builder.package =
  #   inputs.nixpkgs-linux-builder.legacyPackages.${pkgs.stdenv.hostPlatform.system}.darwin.linux-builder;

  homebrew = {
    enable = true;
    enableZshIntegration = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    # so that nix-darwin knows about the taps nix-homebrew brings in
    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [
      "mas" # stop uninstalling it lol
    ];
    greedyCasks = true;
    casks = [
      "orbstack"
      "keepingyouawake"
      "zen@twilight"
      "cloudflare-warp"
      "lulu"
      "ghostty@tip"
      "calibre"
      "tailscale-app"
      "motrix"
      "zed@preview"
    ];
    # disabling until i can use https://github.com/Homebrew/brew/issues/22450
    # masApps = {
    #   Bitwarden = 1352778147;
    #   Telegram = 747648890;
    # };
  };

  my.nix.enable = true;
  my.fonts = {
    enable = true;

    packages = [
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.code-new-roman

      pkgs.inter
      pkgs.googlesans-code
    ];
  };

  system = {
    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

      WindowManager.EnableStandardClickToShowDesktop = false;
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
      NSGlobalDomain.AppleSpacesSwitchOnActivate = false;
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
      NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
      NSGlobalDomain.AppleIconAppearanceTheme = "RegularDark";

      dock.magnification = true;
      dock.orientation = "left";
      dock.largesize = 95;
      dock.tilesize = 25;
      dock.mru-spaces = false;
      dock.showAppExposeGestureEnabled = true;
      dock.persistent-apps = [
        {
          app = "/System/Applications/Apps.app";
        }
        {
          app = "/System/Applications/Mail.app";
        }
        {
          app = "/Applications/Twilight.app";
        }
        {
          app = "/Users/${config.my.username}/Applications/Home Manager Apps/Spotify.app";
        }
        {
          app = "/Applications/Ghostty.app";
        }
        {
          app = "/Applications/Zed Preview.app";
        }
      ];
      dock.persistent-others = [
        {
          folder = {
            path = "/Users/${config.my.username}/Downloads";
            arrangement = "date-modified";
            displayas = "stack";
            showas = "automatic";
          };
        }
      ];

      finder.ShowPathbar = true;

      CustomUserPreferences = {
        NSGlobalDomain.NSGlassTintAmount = 0;
      };
    };

    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToEscape = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      lix = prev.lix.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
      };

      nil = prev.nil.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
      };

      aws-sdk-cpp = prev.aws-sdk-cpp.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
      };

      # https://github.com/NixOS/nixpkgs/issues/507531
      direnv = prev.direnv.overrideAttrs {
        doCheck = false;
      };
    })
  ];

  system.activationScripts = {
    postActivation.text = ''
      # Following line should allow us to avoid a logout/login cycle
      # /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      # set zen as default browser: https://tommorris.org/posts/2024/til-setting-default-browser-on-macos-using-nix/
      ${pkgs.defaultbrowser}/bin/defaultbrowser zen

      # stop update notis: https://discussions.apple.com/thread/255859390
      # defaults write com.apple.SoftwareUpdate MajorOSUserNotificationDate -date "2030-02-07 23:22:47 +0000"
      # defaults write com.apple.SoftwareUpdate UserNotificationDate -date "2030-02-07 23:22:47 +0000"
    '';
  };
}
