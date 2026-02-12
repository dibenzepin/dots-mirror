# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/nixos
    ../../modules/common
  ];

  my.username = "fum";

  ################ filesystems ################

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
    "/swap".options = [ "noatime" ];
  };

  services.btrfs.autoScrub.enable = true;
  swapDevices = [ { device = "/swap/swapfile"; } ];

  ################### boot ###################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  ################ networking ################

  networking.hostName = "bastion";
  networking.networkmanager.enable = true;

  # https://github.com/NixOS/nixos-hardware/blob/master/apple/t2/README.md
  hardware.apple-t2.firmware.enable = true;

  services.resolved.enable = true; # mdns
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node"
    "--operator=${config.my.username}"
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  time.timeZone = "Africa/Lagos";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Set your time zone.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  ################### users ###################

  users = {
    mutableUsers = false;

    users = {
      ${config.my.username} = {
        isNormalUser = true;
        password = "f";
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
          "media"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIv4sj7bHdEikPlNoBOhMCYy96KKBK3sG/lhmxq3s3O3"
        ];
      };

      # strictly for deployments
      colmena = {
        group = "users";
        useDefaultShell = true;
        isSystemUser = true;
        openssh.authorizedKeys.keys = [
          # i'm reusing the key...meh
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIv4sj7bHdEikPlNoBOhMCYy96KKBK3sG/lhmxq3s3O3"
        ];
      };
    };

    groups.media = { }; # tired of wrangling permissions for /media
  };

  security.sudo = {
    extraRules = [
      {
        users = [ "colmena" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nix-store --no-gc-warning --realise /nix/store/*";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-env --profile /nix/var/nix/profiles/system --set /nix/store/*";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/nix/store/*/bin/switch-to-configuration *";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  ################### programs ###################

  my.nix.enable = true;
  my.helix.enable = true;

  nix.package = pkgs.lixPackageSets.stable.lix;

  nixpkgs.overlays = [
    # lix
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  catppuccin.enable = true;
  catppuccin.tty.enable = false; # IFD, see https://github.com/catppuccin/nix/issues/392#issue-2706734348

  programs.fish.enable = true;
  programs.mosh.enable = true;

  systemd.tmpfiles.rules = [
    "d /media 0777 - media -"
  ];

  services.qbittorrent = {
    enable = true;
    group = "media";
    openFirewall = true;
    serverConfig = {
      LegalNotice.Accepted = true;
      BitTorrent.Session = {
        DefaultSavePath = "/media/torrents";
        QueueingSystemEnabled = false;
        FinishedTorrentExportDirectory = "/media/torrents/files";
      };
      Preferences = {
        # https://wiki.archlinux.org/title/QBittorrent#Allow_access_without_username_&_password
        WebUI = {
          # local: 192.168.1.0/24, fddc:fae9:c63b:8::/64, 2605:59c1:1b10:7a08::/64 (i have no idea why we get routed to the external IP over ethernet)
          # https://tailscale.com/docs/reference/reserved-ip-addresses
          AuthSubnetWhitelist = "192.168.1.0/24, fddc:fae9:c63b:8::/64, 2605:59c1:1b10:7a08::/64, 100.64.0.0/10, fd7a:115c:a1e0::/48";
          AuthSubnetWhitelistEnabled = true;
          UseUPnP = false;
          LocalHostAuth = false;
        };
        General.StatusbarExternalIPDisplayed = true;
      };
    };
  };
  systemd.services.qbittorrent.serviceConfig.UMask = "0002"; # default is 022, but i want to give write perms to :media

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [
    pkgs.rocmPackages.clr.icd # opencl
  ];

  # https://wiki.archlinux.org/title/Hardware_video_acceleration#Video_decoding_corruption_or_distortion_with_AMDGPU_driver
  # https://bugs.freedesktop.org/show_bug.cgi?id=106490
  environment.sessionVariables.allow_rgb10_configs = "false";

  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;
  services.jellyfin.group = "media";
  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];

  environment.systemPackages = with pkgs; [
    dnsutils # dig, nslookup
    pciutils # lspci
    usbutils # lsusb
    inetutils # whois
    file
    ghostty.terminfo
    clinfo
    radeontop
    libva-utils
    vulkan-tools
  ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
