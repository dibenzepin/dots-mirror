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

  my.username = "fumnanya";

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
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ################ networking ################

  networking.hostName = "bastion";
  networking.networkmanager.enable = true;
  services.resolved.enable = true; # mdns
  services.tailscale.enable = true;
  services.tailscale.extraSetFlags = [ "--ssh" ];

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
    defaultUserShell = pkgs.zsh;

    users = {
      ${config.my.username} = {
        isNormalUser = true;
        password = "f";
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIv4sj7bHdEikPlNoBOhMCYy96KKBK3sG/lhmxq3s3O3"
        ];
      };

      # strictly for deployments
      colmena = {
        group = "colmena";
        useDefaultShell = true;
        isSystemUser = true;
        openssh.authorizedKeys.keys = [
          # i'm reusing the key...meh
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIv4sj7bHdEikPlNoBOhMCYy96KKBK3sG/lhmxq3s3O3"
        ];
      };
    };

    groups.colmena = { };
  };

  security.sudo = {
    extraRules = [
      {
        groups = [ "colmena" ];
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
  my.zsh.enable = true;
  my.helix.enable = true;

  # ghostty et al.
  environment.enableAllTerminfo = true;

  nixpkgs.overlays = [
    (final: prev: {
      lix = prev.lix.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
      };
    })
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/speeds 0777 - - -"
  ];

  systemd.timers = {
    speedtest = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "15m";
        RandomizedDelaySec = "2m";
        Unit = "speedtest.service";
        Persistent = true;
      };
    };
  };

  systemd.services = {
    speedtest = {
      path = [
        pkgs.fast-cli
        pkgs.ookla-speedtest
      ];
      script = ''
        fastdate=$(date -u '+%Y-%m-%dT%H:%M:%S.000')
        fast -u --json > "/var/lib/speeds/fast-$fastdate.json"

        ookladate=$(date -u '+%Y-%m-%dT%H:%M:%S.000')
        HOME=/var/lib/speeds speedtest -f json-pretty --accept-license --accept-gdpr > "/var/lib/speeds/ookla-$ookladate.json"
      '';
      serviceConfig = {
        Type = "oneshot";
        TimeoutSec = 120;
      };
    };
  };

  # environment.systemPackages = with pkgs; [
  #   dnsutils # dig, nslookup
  #   pciutils # lspci
  #   usbutils # lsusb
  #   inetutils # whois
  #   file
  # ];

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
  system.stateVersion = "25.05"; # Did you read the comment?
}
