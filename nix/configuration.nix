# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./filesystems.nix
      ./services/caddy/default.nix
      ./services/diun/default.nix
      ./services/gotify/default.nix
      ./services/homer/default.nix
      ./services/jellyfin/default.nix
      ./services/jellyseerr/default.nix
      ./services/mongo/default.nix
      ./services/mosquitto/default.nix
      ./services/postgres/default.nix
      ./services/prowlarr/default.nix
      ./services/radarr/default.nix
      ./services/scrutiny/default.nix
      ./services/smokeping/default.nix
      ./services/sonarr/default.nix
      ./services/transmission/default.nix
      ./services/unifi/default.nix
      ./services/uptime-kuma/default.nix
      ./services/watchstate/default.nix
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
    mergerfs-tools
    snapraid
    vim
    wget
  ];

  programs.zsh.enable = true;

  users.groups.family   = {};
  users.groups.media    = {};
  users.groups.services = {};

  users.users =
    let commonCfg =
      { createHome   = false;
        extraGroups  = [ "family" ];
        isNormalUser = true;
        shell        = pkgs.zsh;
      };
      commonSvcCfg =
      { createHome   = false;
        group        = "services";
        isSystemUser = true;
      };
    in
      { "rich"   = (commonCfg // { createHome = true; extraGroups = [ "family" "media" "wheel" ]; });
        "kate"   = commonCfg;
        "calvin" = commonCfg;
        "emma"   = commonCfg;
        "lucas"  = commonCfg;

        "caddy"        = commonSvcCfg;
        "diun"         = commonSvcCfg;
        "gotify"       = commonSvcCfg;
        "homer"        = commonSvcCfg;
        "jellyfin"     = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "mongo"        = commonSvcCfg;
        "mosquitto"    = commonSvcCfg;
        "jellyseerr"   = commonSvcCfg;
        "postgres"     = commonSvcCfg;
        "prowlarr"     = commonSvcCfg;
        "radarr"       = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "smokeping"    = commonSvcCfg;
        "sonarr"       = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "transmission" = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "unifi"        = commonSvcCfg;
        "watchstate"   = commonSvcCfg;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}