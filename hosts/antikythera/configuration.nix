# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  pkgs,
  inputs,
  config,
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

  # btrfs config options + swap
  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/home".neededForBoot = true; # hashedPasswordFile is stored here
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
    "/swap".options = [ "noatime" ];
  };

  services.btrfs.autoScrub.enable = true;

  swapDevices = [ { device = "/swap/swapfile"; } ];

  ################### boot ###################

  # Use the grub boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.configurationLimit = 10;

  distro-grub-themes = {
    enable = true;
    theme = "nixos";
  };

  ################ networking ################

  networking.hostName = "antikythera"; # Define your hostname.

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # changing to systemd-resolved allows for .local because of built in mdns + networkmanager
  services.resolved.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Lagos";

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

  ################# hardware #################

  services.fwupd.enable = true;
  hardware.enableAllFirmware = true;
  hardware.graphics.enable32Bit = true; # enable Vulkan for 32-bit apps

  #################### ui ####################

  my.gnome = {
    enable = true;
    browser = "firefox-nightly";
    terminal = "kitty";
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # caps acts as escape except when shifted
  #
  # apparently gnome only uses this for initial setup
  # so changing it later requires `gsettings reset org.gnome.desktop.input-sources xkb-options`
  # https://discourse.nixos.org/t/problem-with-xkboptions-it-doesnt-seem-to-take-effect/5269/2
  # https://unix.stackexchange.com/a/749423
  #
  # todo: look into just spitting out the dconf
  services.xserver.xkb.options = "caps:escape_shifted_capslock";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  ################### users ###################

  # installing with --no-root-passwd
  users.mutableUsers = false;

  # zsh for everyone!!
  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${config.my.username} = {
    isNormalUser = true;
    hashedPasswordFile = "/home/${config.my.username}/.hashed_password";
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "networkmanager"
    ];
    #   packages = with pkgs; [
    #     tree
    #   ];
  };

  ################### programs ###################

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    (curl.override { c-aresSupport = true; }) # need c-ares for curl --dns-resolvers
    dnsutils # dig, nslookup
    pciutils # lspci
    usbutils # lsusb
    inetutils # whois
    file
    xclip
    nix-search-cli
    _7zz
  ];

  programs.nix-ld.enable = true;
  services.cloudflare-warp.enable = true;

  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

  virtualisation.podman.enable = true;
  virtualisation.podman.extraPackages = [ pkgs.docker-compose ];

  services.zabbixAgent = {
    enable = true;
    server = "debby.verraki";
    openFirewall = true;
    package = pkgs.zabbix.agent2;
    settings = {
      DebugLevel = 5;
      ServerActive = "debby.verraki";
    };
  };

  # why not? :)
  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  my.nix.enable = true;
  my.zsh.enable = true;
  my.helix.enable = true;
  my.goldwarden.enable = true;

  my.fonts = {
    enable = true;

    packages =
      with pkgs;
      [
        freefont_ttf
        gyre-fonts
        liberation_ttf
        unifont

        corefonts
        vistafonts
        source-serif
        inter

        nerd-fonts.fira-code
        nerd-fonts.code-new-roman

        inputs.apple-emoji.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]
      ++ (with inputs.fum.packages.${pkgs.stdenv.hostPlatform.system}; [
        helvetica
        helvetica-neue
      ]);

    default = {
      emoji = [ "Apple Color Emoji" ];
      mono = [ "FiraCode Nerd Font Mono" ];
      sans = [ "Inter" ];
      serif = [ "Source Serif 4" ];
    };

    conf = ''
      <?xml version='1.0'?>

      <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>

      <fontconfig>
        <match target="pattern">
          <test qual="any" name="family" compare="eq"><string>BlinkMacSystemFont</string></test>
          <edit name="family" mode="assign" binding="same"><string>sans-serif</string></edit>
        </match>

        <match target="pattern">
          <test qual="any" name="family" compare="eq"><string>-apple-system</string></test>
          <edit name="family" mode="assign" binding="same"><string>sans-serif</string></edit>
        </match>

        <match target="pattern">
          <test qual="any" name="family" compare="eq"><string>ui-monospace</string></test>
          <edit name="family" mode="assign" binding="same"><string>monospace</string></edit>
        </match>
      </fontconfig>
    '';
  };

  nixpkgs.overlays = [
    # since gnome-keyring still enables its sshagent by default: https://github.com/NixOS/nixpkgs/blob/88195a94f390381c6afcdaa933c2f6ff93959cb4/pkgs/by-name/gn/gnome-keyring/package.nix#L67
    # which forces $SSH_AUTH_SOCK to be set by it: https://github.com/NixOS/nixpkgs/issues/8356
    # if they switch to gcr, then there should be an easier way to disable it: https://github.com/NixOS/nixpkgs/issues/166887, https://github.com/NixOS/nixpkgs/pull/284173
    # thefted from https://discourse.nixos.org/t/disable-ssh-agent-from-gnome-keyring-on-gnome/28176/6
    # see also https://github.com/NixOS/nixpkgs/pull/379731
    (final: prev: {
      gnome-keyring = prev.gnome-keyring.overrideAttrs (oldAttrs: {
        mesonFlags = (builtins.filter (flag: flag != "-Dssh-agent=true") oldAttrs.mesonFlags) ++ [
          "-Dssh-agent=false"
        ];
      });
    })
  ];

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
  system.stateVersion = "24.11"; # Did you read the comment?
}
