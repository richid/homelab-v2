# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services/scrutiny/default.nix
      ./services/smokeping/default.nix
    ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot  = false;

  hardware.cpu.intel.updateMicrocode = true;

  networking = {
    hostId   = "deadbeef";
    hostName = "gibson";
    firewall.enable = false;

    bonds = {
      bond0 = {
        interfaces = [ "enp4s0f0" "enp4s0f1" ];
        driverOptions = {
          miimon = "100";
          mode = "802.3ad";
        };
      };
    };

    interfaces = {
      eno1 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.10.100";
          prefixLength = 24;
        }];
      };
    };

    defaultGateway = "192.168.10.1";
    nameservers    = [ "192.168.20.10" ];
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  environment.variables.EDITOR = "vim";
  environment.systemPackages = with pkgs; [
    du-dust
    dua
    duf
    htop
    mergerfs
    snapraid
    vim
    wget
    xfsprogs
  ];

  programs.zsh.enable = true;
  users.groups.family = {};

  users.users =
    let commonCfg =
      { createHome   = false;
        extraGroups  = [ "family" ];
        isNormalUser = true;
        shell        = pkgs.zsh;
      };
    in
      { "rich"   = (commonCfg // { createHome = true; extraGroups = [ "family" "wheel" ]; });
        "kate"   = commonCfg;
        "calvin" = commonCfg;
        "emma"   = commonCfg;
        "lucas"  = commonCfg;
      };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin        = "yes";
    };
  };

  services.smartd = {
    enable = true;
    notifications.wall.enable = true;
  };

  virtualisation.docker = {
    autoPrune.enable = true;
    autoPrune.dates  = "weekly";
    enableOnBoot     = true;
  };

  virtualisation.oci-containers.backend = "docker";

  # filesystems.nix
  services.zfs = {
    autoScrub.enable = true;
    zed.settings = {
      ZED_DEBUG_LOG            = "/tmp/zed.debug.log";
      ZED_SCRUB_AFTER_RESILVER = true;
    };
    zed.enableMail = false;
  };

  fileSystems = {
    "/mnt/app-data" = {
      device = "app-data";
      fsType = "zfs";
      label  = "app-data";
    };

    "/mnt/parity0" = {
      device  = "/dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA218QZ0";
      fsType = "ext4";
      label  = "parity0";
    };

    "/mnt/parity1" = {
      device  = "/dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA21BXT1";
      fsType = "ext4";
      label  = "parity1";
    };

    "/mnt/data0" = {
      device  = "/dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA20WPHN";
      fsType = "ext4";
      label  = "data0";
    };

    "/mnt/tank" = {
      device  = "/mnt/data*";
      fsType  = "fuse.mergerfs";
      options = [
        "defaults"
        "minfreespace=10G"
        "func.getattr=newest"
        "fsname=tank"
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}