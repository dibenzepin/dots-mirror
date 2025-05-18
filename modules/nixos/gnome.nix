{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.gnome;
  uname = config.my.username;
  wallpaper = ./steven.png;
in
with lib;
{
  options = {
    my.gnome = {
      enable = mkEnableOption "gnome windowing system for nixos";
      terminal = mkOption {
        type = types.str;
        default = null;
      };
      browser = mkOption {
        type = types.str;
        default = null;
      };
      wallpaper = mkOption {
        type = types.path;
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    # actually "xserver" means "gui applications pls"
    # gdm uses wayland
    services.xserver = {
      enable = true;

      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      # rm xterm
      excludePackages = [ pkgs.xterm ];
    };

    environment.systemPackages =
      (with pkgs; [
        gnome-firmware
        gnome-extension-manager
        resources
        gnome-tweaks
        gjs # cos of auto-accent
      ])
      ++ (with pkgs.gnomeExtensions; [
        thinkpad-battery-threshold
        run-or-raise
        places-status-indicator
        cloudflare-warp-toggle
        tiling-assistant
        caffeine
        pip-on-top
        # auto-accent-colour
      ]);

    # stem darkening in an attempt to make fonts look better
    # https://x.com/luciascarlet/status/1857965489424589000
    # https://new.reddit.com/r/linux_gaming/comments/16lwgnj/is_it_possible_to_improve_font_rendering_on_linux/
    environment.sessionVariables = {
      FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0 type1:no-stem-darkening=0 t1cid:no-stem-darkening=0";
    };

    environment.gnome.excludePackages = with pkgs; [
      # i replace these with:
      geary # thunderbird
      totem # celluloid
      gnome-maps
      gnome-music
      gnome-system-monitor # resources
      gnome-console # kitty
      gnome-shell-extensions
      gnome-tour
      file-roller # nautilus can do basic (un)compression
    ];

    xdg.mime = {
      enable = true;
      defaultApplications = {
        "text/plain" = "org.gnome.TextEditor.desktop";

        # chrome just sets itself to open everything
        "application/pdf" = "${cfg.browser}.desktop";
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";

        # nautlilus doesn't want to extract them for some reason
        "application/zip" = "org.gnome.Nautilus.desktop";
        "application/x-7z-compressed" = "org.gnome.Nautilus.desktop";
        "application/x-compressed-tar" = "org.gnome.Nautilus.desktop";
        "application/vnd.rar" = "org.gnome.Nautilus.desktop";
        "application/x-xz-compressed-tar" = "org.gnome.Nautilus.desktop";
      };
    };

    # so that gtk-launch doesn't use gnome-console
    # https://askubuntu.com/a/1262935
    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [ "${cfg.terminal}.desktop" ];
      };
    };

    # make nautilus use kitty
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = cfg.terminal;
    };

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          lockAll = true;
          settings = with lib.gvariant; {

            "org/gnome/desktop/interface".color-scheme = "prefer-dark";

            "org/gnome/shell" = {
              disable-user-extensions = false; # enables user extensions

              enabled-extensions = with pkgs.gnomeExtensions; [
                gsconnect.extensionUuid
                thinkpad-battery-threshold.extensionUuid
                places-status-indicator.extensionUuid
                run-or-raise.extensionUuid
                cloudflare-warp-toggle.extensionUuid
                tiling-assistant.extensionUuid
                caffeine.extensionUuid
                pip-on-top.extensionUuid
                # auto-accent-colour.extensionUuid
                # "auto-accent-colour@Wartybix"
              ];

              favorite-apps = [
                "firefox-nightly.desktop"
                "code.desktop"
                "kitty.desktop"
                "spotify.desktop"
                "thunderbird.desktop"
                "org.gnome.Nautilus.desktop"
              ];
            };

            "org/gnome/desktop/background" = {
              picture-uri = "file://${wallpaper}";
              picture-uri-dark = "file://${wallpaper}";
            };

            "org/gnome/desktop/screensaver" = {
              picture-uri = "file://${wallpaper}";
            };

            "org/gnome/mutter".dynamic-workspaces = true;
            "org/gnome/shell/app-switcher".current-workspace-only = true;
            "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,close";
            "org/gnome/desktop/peripherals/touchpad".accel-profile = "flat";
            "org/gnome/mutter".attach-modal-dialogs = true;

            # lots of confusing things on the internet, for me this looks okay
            # https://x.com/luciascarlet/status/1857965489424589000
            "org/gnome/desktop/interface".font-hinting = "full";
            "org/gnome/desktop/interface".font-antialiasing = "grayscale";

            "org/gnome/desktop/wm/keybindings" = {
              # by default these are <Super>space and <Shift><Super>space
              # run-or-raise wants <Super>space
              switch-input-source = mkEmptyArray type.string;
              switch-input-source-backward = mkEmptyArray type.string;

              # switching windows with <Alt>Tab makes more sense
              switch-applications = mkEmptyArray type.string;
              switch-applications-backward = mkEmptyArray type.string;
              switch-windows = [ "<Alt>Tab" ];
              switch-windows-backward = [ "<Shift><Alt>Tab" ];
            };

            # screen blank after 3 min.
            "org/gnome/desktop/session".idle-delay = mkUint32 180;

            # on battery sleep after 5/15 min on battery/ac
            "org/gnome/settings-daemon/plugins/power".sleep-inactive-battery-timeout = mkInt32 300;
            "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-timeout = mkInt32 900;

            "org/gnome/shell/extensions/thinkpad-battery-threshold" = {
              start-bat0 = mkUint32 75;
              end-bat0 = mkUint32 80;
              indicator-mode = "NEVER";
            };

            "org/gnome/shell/extensions/auto-accent-colour".hide-indicator = true;
            "org/gnome/shell/extensions/auto-accent-colour".disable-cache = true;
          };
        }
      ];
    };

    # TODO: home-manager abuse!
    # this is me being lazy and assuming hm exists
    home-manager.users.${uname} = {
      gtk = {
        enable = true;
        cursorTheme = {
          name = "GoogleDot-Black";
          package = pkgs.google-cursor;
        };
        font = {
          name = "Inter";
          size = 11;
        };
      };

      xdg.configFile."run-or-raise/shortcuts.conf".text = ''
        # needs run-or-raise GNOME extension
        # https://github.com/CZ-NIC/run-or-raise

        # switches back and forth between kitty windows
        <Super>Space:switch-back-when-focused,kitty,kitty,
      '';
    };
  };
}
