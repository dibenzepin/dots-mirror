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

  homebrew =
    # stolen from https://github.com/nix-darwin/nix-darwin/issues/935#issuecomment-2096813988
    let
      mkGreedy = caskName: {
        name = caskName;
        greedy = true;
      };
    in
    {
      enable = true;
      onActivation = {
        cleanup = "zap";
        upgrade = true;
      };
      # so that nix-darwin knows about the taps nix-homebrew brings in
      taps = builtins.attrNames config.nix-homebrew.taps;
      brews = [
        "mas" # stop uninstalling it lol
      ];
      casks = map mkGreedy [
        "orbstack"
        "keepingyouawake"
        "zen"
        "cloudflare-warp"
        "lulu"
        "ghostty@tip"
        "calibre"
        # "kdeconnect" # go and automate it
      ];
      masApps = {
        Bitwarden = 1352778147;
        Telegram = 747648890;
      };
    };

  my.nix.enable = true;
  my.fonts = {
    enable = true;

    packages =
      with pkgs.nerd-fonts;
      [
        fira-code
        code-new-roman
      ]
      ++ (with pkgs; [
        inter
      ]);
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

      dock.magnification = true;
      dock.orientation = "left";
      dock.largesize = 95;
      dock.tilesize = 25;
      dock.mru-spaces = false;
      dock.persistent-apps = [
        {
          app = "/System/Applications/Apps.app";
        }
        {
          app = "/System/Applications/Mail.app";
        }
        {
          app = "/Applications/Zen.app";
        }
        {
          app = "/Users/${config.my.username}/Applications/Home Manager Trampolines/Spotify.app";
        }
        {
          app = "/Applications/Ghostty.app";
        }
        {
          app = "/Users/${config.my.username}/Applications/Home Manager Trampolines/Zed.app";
        }
      ];
      dock.persistent-others = [
        "/Users/${config.my.username}/Downloads"
      ];

      finder.ShowPathbar = true;

      CustomUserPreferences = {
        NSGlobalDomain.AppleIconAppearanceTheme = "ClearAutomatic"; # liquid glass!!!
        # "com.apple.SoftwareUpdate" = {
        #   "MajorOSUserNotificationDate" = "2030-02-07 23:22:47 +0000";
        #   "UserNotificationDate" = "2030-02-07 23:22:47 +0000";
        # };
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
    })
  ];

  system.activationScripts = {
    # preActivation.text = ''
    # homebrew doesn't understand that there's updates sometimes
    # rm -r /opt/homebrew/Caskroom/*
    # '';

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
