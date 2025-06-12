# nixos

got a flash drive and a nice PC that needs some Linux love?

1.  Boot it up. The easiest way to get up and running is to bootstrap a minimal install with _just_ enough to get you the config (so `nix`, `wget`, and `git` really[^2]) and then switch into it from there.
1.  Partition your disks. You could use `parted` or `fdisk`, but I'm not skilled enough for that, so _GNOME Disks_ or _GParted_ works for me. You want:
    - an EFI partition (1 GB should be fine) for your boot files, and
    - a BTRFS partition where everything else lives.
1.  Make some subvolumes in the BTRFS partition from step 2. We're stealing a lot from the [NixOS wiki entry for BTRFS](https://wiki.nixos.org/wiki/Btrfs), the [unofficial NixOS wiki entry](https://nixos.wiki/wiki/Btrfs), and the [Arch Wiki entry](wiki.archlinux.org/title/Btrfs):
    ```sh
    $ mount /dev/nvme0n1p2 /mnt
    $ btrfs subvolume create /mnt/root
    $ btrfs subvolume create /mnt/home
    $ btrfs subvolume create /mnt/nix
    $ btrfs subvolume create /mnt/swap
    $ unmount /mnt
    ```
1.  Mount these subvolumes:
    ```sh
    $ mount -o compress=zstd,subvol=root /dev/nvme0n1p2 /mnt
    $ mkdir /mnt/{home,nix,swap,boot}
    $ mount -o compress=zstd,subvol=home /dev/nvme0n1p2 /mnt/home
    $ mount -o compress=zstd,noatime,subvol=nix /dev/nvme0n1p2 /mnt/nix
    $ mount -o noatime,subvol=swap /dev/nvme0n1p2 /mnt/swap
    $ mount -o umask=077 /dev/nvme0n1p1 /mnt/boot
    ```
1.  Make some swap:
    ```sh
    $ btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/swap/swapfile
    $ swapon
    ```
1.  Generate your configuration:
    ```sh
    $ nixos-generate-config --root /mnt
    ```
1.  Edit `/mnt/configuration.nix` to look something like:
    ```nix
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

    environment.systemPackages = [
        helix
        wget
        git
    ];

    users.mutableUsers = false;
    users.defaultShell = pkgs.zsh;
    users.users.fumnanya = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "f";
    };

    networking.hostname = "antikythera";
    networking.networkmanager.enable = true;

    programs.zsh.enable = true;
    services.xserver.enable = false;
    ```
1. Install and reboot:
    ```sh
    $ nixos-install --no-root-password
    ```
1.  Once rebooted, you can get this repo and then switch into a config:
    ```sh
    $ nixos-rebuild --flake /path/to/repo#hostname`
    ```
1.  For ease of use with `nixos-rebuild`, symlink the expected location to your local clone:
    ```sh
    $ sudo ln -s ~/dots /etc/nixos
    ```

[^2]: Cloudflare WARP may or may not be needed depending on your local country's laws.
