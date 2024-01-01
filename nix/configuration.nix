# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./filesystems.nix
      ./services/caddy/default.nix
      ./services/diun/default.nix
      ./services/gotify/default.nix
      ./services/grafana/default.nix
      ./services/homer/default.nix
      ./services/influxdb/default.nix
      ./services/jellyfin/default.nix
      ./services/jellyseerr/default.nix
      ./services/minecraft/default.nix
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
          mode   = "802.3ad";
        };
      };
    };

    interfaces = {
      # Control plane
      eno1 = {
        useDHCP = false;

        ipv4.addresses = [{
          address      = "192.168.10.100";
          prefixLength = 24;
        }];

      };

      # Bonded NICs for services
      bond0 = {
        useDHCP = false;

        ipv4.addresses = [{
          address      = "192.168.20.195";
          prefixLength = 24;
        }];
      };

      # Dedicated interface to allow host-> container communication
      services-bridge = {
        useDHCP = false;

        ipv4.addresses = [{
          address      = "192.168.20.199";
          prefixLength = 24;
        }];

        # Static route to container IPs
        ipv4.routes = [{
          address      = "192.168.20.192";
          prefixLength = 26;
        }];
      };
    };

    defaultGateway = "192.168.10.1";
    nameservers    = [ "192.168.20.10" ];

    macvlans.services-bridge = {
      interface = "bond0";
      mode      = "bridge";
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/162260
  systemd.services.network-addresses-services-bridge = {
    after = [ "dhcpcd.service" ];
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  environment.variables.EDITOR = "vim";
  environment.systemPackages = with pkgs; [
    croc
    du-dust
    dua
    duf
    htop
    jdupes
    jq
    mergerfs
    mergerfs-tools
    rclone
    snapraid
    vim
    wget
  ];

  environment.etc."nut/upsd.conf".source   = ./nut/upsd.conf;
  environment.etc."nut/upsd.users".source  = ./nut/upsd.users;
  environment.etc."nut/upsmon.conf".source = ./nut/upsmon.conf;

  power.ups = {
    enable = true;

    ups.gibson = {
      driver      = "usbhid-ups";
      port        = "auto";
      description = "Eaton 5P UPS";
    };
  };

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

        "backups"      = commonSvcCfg;
        "caddy"        = commonSvcCfg;
        "diun"         = commonSvcCfg;
        "gotify"       = commonSvcCfg;
        "grafana"      = commonSvcCfg;
        "homer"        = commonSvcCfg;
        "influxdb"     = commonSvcCfg;
        "jellyfin"     = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "minecraft"    = commonSvcCfg;
        "mongo"        = commonSvcCfg;
        "mosquitto"    = commonSvcCfg;
        "nut"          = commonSvcCfg // { createHome = true; home = "/var/lib/nut"; password = "nut"; };
        "jellyseerr"   = commonSvcCfg;
        "postgres"     = commonSvcCfg;
        "prowlarr"     = commonSvcCfg;
        "radarr"       = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "smokeping"    = commonSvcCfg;
        "sonarr"       = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "transmission" = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "unifi"        = commonSvcCfg;
        "vector"       = commonSvcCfg // { extraGroups = [ "docker" ]; };
        "watchstate"   = commonSvcCfg;
      };

  security.sudo.extraRules= [{
    users = [ "rich" ];
    commands = [{
      command = "ALL" ;
      options= [ "NOPASSWD" ];
    }];
  }];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin        = "yes";
    };
  };

  services.restic.backups = {
    gdrive = {
      user             = "backups";
      repository       = "rclone:gdrive:/Backups";
      paths            = [ "/mnt/dozer/Dropbox" ];
      passwordFile     = "/etc/nixos/restic-password";
      rcloneConfigFile = "/etc/nixos/rclone.conf";

      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
    };
  };

  services.smartd = {
    enable = true;
    notifications.wall.enable = true;
  };

  services.vector = {
    enable         = true;
    journaldAccess = true;

    settings = {
      api = {
        enabled = true;
        address = "0.0.0.0:8686";
      };

      data_dir = "/mnt/app-data/vector";

      sources = {
        docker_logs = {
          type = "docker_logs";
        };

        vector_logs = {
          type = "internal_logs";
        };

        host_metrics = {
          type       = "host_metrics";
          collectors = [ "cgroups" "cpu" "disk" "filesystem" "load" "host" "memory" "network" ];
          namespace  = "gibson";

          #disk.devices.includes           = [ "sd*" "nvme*" ];
          #filesystem.devices.includes     = [ "sd*" "nvme*" ];
          #filesystem.filesystems.includes = [ "ext*" "fuse.mergerfs" "zfs" ];

          scrape_interval_secs = 10;
        };

        journald_logs = {
          type = "journald";
        };
      };

      sinks = {
        console = {
          type   = "console";
          inputs = [ "vector_logs" ];

          encoding.codec = "text";
        };

        loki_docker = {
          type     = "loki";
          inputs   = [ "docker_logs" ];
          endpoint = "http://192.168.20.227:3100";
          labels   = {
            source           = "docker";
            docker_id      = "{{ container_id }}";
            docker_created = "{{ container_created_at }}";
            docker_name    = "{{ container_name }}";
            docker_image   = "{{ image }}";
            docker_stream  = "{{ stream }}";
          };

          encoding.codec = "text";
        };

        loki_journald = {
          type     = "loki";
          inputs   = [ "journald_logs" ];
          endpoint = "http://192.168.20.227:3100";
          labels   = {
            source        = "journald";
            journald_unit = "{{ _SYSTEMD_UNIT }}";
          };

          encoding.codec = "text";
        };

        influxdb_host_metrics = {
          type     = "influxdb_metrics";
          inputs   = [ "host_metrics" ];
          bucket   = "system_metrics";
          org      = "temple";
          endpoint = "http://192.168.20.228:8086";
          token    = "sBBOqs-3OEJNdCe_K0fPw7M_BzWM0oJ4o0M6tzsEZcNHjB42kS2wYxm3ECpyBdBt44XP63fQLiU79LqQmwzZjw==";
        };
      };
    };
  };

  # Don't let systemd use an ephemeral user, we want to use our own
  # so we have appropriate permissions to the /mnt/app-data/vector ZFS dataset.
  # https://github.com/NixOS/nixpkgs/blob/bd1cde45c77891214131cbbea5b1203e485a9d51/nixos/modules/services/logging/vector.nix#L53C11-L53C22
  systemd.services.vector.serviceConfig.DynamicUser = lib.mkForce false;
  systemd.services.vector.serviceConfig.User        = lib.mkForce "vector";
  systemd.services.vector.serviceConfig.Group       = lib.mkForce "services";

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