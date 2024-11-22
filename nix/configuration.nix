# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
  secrets = import ./secrets.nix;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./filesystems.nix
    ] ++ lib.pipe ./services [
      builtins.readDir
      (lib.filterAttrs (name: _: lib.hasSuffix ".nix" name))
      (lib.mapAttrsToList (name: _: ./services + "/${name}"))
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
    nvme-cli
    rclone
    screen
    smartmontools
    snapraid
    vim
    wget
  ];

  power.ups = {
    enable = true;

    ups.gibson = {
      driver      = "usbhid-ups";
      port        = "auto";
      description = "Eaton 5P UPS";
    };

    users.upsmon = {
      passwordFile = "/etc/nixos/conf/upsmon.password";
      upsmon = "master";
    };

    upsmon.monitor.gibson.user = "upsmon";
  };

  programs.zsh.enable = true;

  users.groups.family   = {};
  users.groups.media    = {};
  users.groups.services = {};
  users.groups.docker.members = [ "telegraf" ];

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

        "audiobookshelf" = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "backups"        = commonSvcCfg;
        "caddy"          = commonSvcCfg;
        "diun"           = commonSvcCfg;
        "gotify"         = commonSvcCfg;
        "grafana"        = commonSvcCfg;
        "homer"          = commonSvcCfg;
        "influxdb"       = commonSvcCfg;
        "jellyfin"       = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "minecraft"      = commonSvcCfg;
        "mongo"          = commonSvcCfg;
        "mosquitto"      = commonSvcCfg;
        "jellyseerr"     = commonSvcCfg;
        "postgres"       = commonSvcCfg;
        "prowlarr"       = commonSvcCfg;
        "radarr"         = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "smokeping"      = commonSvcCfg;
        "sonarr"         = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "tandoor"        = commonSvcCfg;
        "transmission"   = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "tunarr"         = commonSvcCfg // { group = "media"; extraGroups = [ "services" ]; };
        "unifi"          = commonSvcCfg;
        "watchstate"     = commonSvcCfg;
      };

  security.sudo.extraRules= [{
    users = [ "rich" "telegraf" ];
    commands = [{
      command = "ALL" ;
      options = [ "NOPASSWD" ];
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
      passwordFile     = "/etc/nixos/conf/restic-password";
      rcloneConfigFile = "/etc/nixos/conf/rclone.conf";

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

  services.telegraf = {
    enable = true;

    extraConfig = {
      global_tags = { };

      agent = {
        interval = 10;
      };

      inputs = {
        bond = {
          bond_interfaces = [ "bond0" ];
        };
        cpu = {
          collect_cpu_time = false;
          core_tags = false;
          percpu = true;
          report_active = false;
          totalcpu = true;
        };
        disk = {
          mount_points = [ "/" "/mnt/tank" ];
        };
        diskio = {
          name_templates = [ "$ID_FS_LABEL" ];
        };
        docker = {
          perdevice = false;
          perdevice_include = [ "blkio" "cpu" "network" ];
          total = false;
        };
        docker_log = {
          from_beginning = false;
          docker_label_exclude = [ "*" ];
          tags = {
            bucket = "system_logs";
          };
        };
        exec = {
          interval = "1h";
          commands = [ "/etc/nixos/scripts/zpool_capacity.sh" ];
          data_format = "influx";
        };
        filecount = {
          directories = [ "/mnt/tank/Media/Movies" "/mnt/tank/Media/TV" ];
          follow_symlinks = true;
          size = "25MB";
        };
        mem = { };
        mongodb = {
          servers = [ "mongodb://mongo44.fatsch.us:27017/?connect=direct" ];
          tags = {
            bucket = "database_metrics";
          };
        };
        net = {
          ignore_protocol_stats = true;
          interfaces = [ "bond0" "eno1" "enp*" ];
        };
        netstat = { };
        #postgresql = {

        #  tags = {
        #    bucket = "database_metrics";
        #  };
        #}
        #intel_powerstat = {
        #  package_metrics = ["current_power_consumption" "thermal_design_power"];
        #  cpu_metrics = ["cpu_frequency" "cpu_temperature"];
        #};
        smart = {
          interval = "1h";
          path_smartctl = "${pkgs.smartmontools}/bin/smartctl";
          path_nvme = "${pkgs.nvme-cli}/bin/nvme";
          use_sudo = true;
          attributes = false;
        };
        swap = { };
        system = { };
        upsd = {
          port = 3493;
          server = "127.0.0.1";
        };
        zfs = {
          poolMetrics = true;
          datasetMetrics = true;

          fielddrop = [ "zil*" "arc*" ];
        };
      };

      outputs = {
        file = {
          data_format = "influx";
          files = [ "stdout" ];
          namepass = [ "docker_log*" ];
        };
        influxdb_v2 = {
          urls = [ "https://influx.fatsch.us" ];
          organization = "temple";
          token = secrets.telegraf.influxdb.token;

          bucket = "system_metrics";
          bucket_tag = "bucket";
          exclude_bucket_tag = true;
        };
      };
    };
  };

  systemd.services.telegraf.path = [ pkgs.smartmontools "/run/wrappers" ];

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