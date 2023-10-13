{
  services.zfs = {
    autoScrub.enable = true;
    zed.settings = {
      ZED_DEBUG_LOG            = "/tmp/zed.debug.log";
      ZED_SCRUB_AFTER_RESILVER = true;
    };
    zed.enableMail = false;
  };

  # Note: Not enabling avahi/mDNS since this is running on the MGMT VLAN which
  # does not have mDNS enabled. All other VLANs do have this enabled, so it
  # may be possible to run and advertise this in a container?
  services.samba = {
    enable       = true;
    securityType = "user";

    # [global] Samba section
    extraConfig = ''
      browseable  = yes
      smb encrypt = required

      veto files        = /._*/.DS_Store/
      delete veto files = yes
    '';

    shares = {
      Backups = {
        path             = "/mnt/dozer/Backups";
        browseable       = "yes";
        "read only"      = "no";
        "guest ok"       = "yes";
        "create mask"    = "0744";
        "directory mask" = "0755";
        "force group"    = "family"; # hurrrhwaa?
      };
      Dropbox = {
        path             = "/mnt/dozer/Dropbox";
        browseable       = "yes";
        "read only"      = "no";
        "guest ok"       = "yes";
        "create mask"    = "0744";
        "directory mask" = "0755";
        "force group"    = "family";
      };
      Media = {
        path             = "/mnt/tank/Media";
        browseable       = "yes";
        "read only"      = "no";
        "guest ok"       = "yes";
        "create mask"    = "0744";
        "directory mask" = "0755";
        "force group"    = "media";
      };
    };
  };

  fileSystems = {
    "/mnt/app-data" = {
      device = "app-data";
      fsType = "zfs";
      label  = "app-data";
    };

    "/mnt/dozer" = {
      device = "dozer";
      fsType = "zfs";
      label  = "dozer";
    };

    "/mnt/parity0" = {
      device = "/dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA218QZ0";
      fsType = "ext4";
      label  = "parity0";
    };

    "/mnt/parity1" = {
      device = "/dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA21BXT1";
      fsType = "ext4";
      label  = "parity1";
    };

    "/mnt/data0" = {
      device = "/dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA20WPHN";
      fsType = "ext4";
      label  = "data0";
    };

    "/mnt/data1" = {
      device = "/dev/disk/by-id/ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K1CZK8JC";
      fsType = "ext4";
      label  = "data1";
    };

    "/mnt/data2" = {
      device = "/dev/disk/by-id/ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K2JYLLHL";
      fsType = "ext4";
      label  = "data2";
    };

    "/mnt/data3" = {
      device = "/dev/disk/by-id/ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K2LD2NTR";
      fsType = "ext4";
      label  = "data3";
    };

    "/mnt/data4" = {
      device = "/dev/disk/by-id/ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K4FEACY1";
      fsType = "ext4";
      label  = "data4";
    };

    "/mnt/data5" = {
      device = "/dev/disk/by-id/ata-WDC_WD40EURX-64WRWY0_WD-WCC4E1745891";
      fsType = "ext4";
      label  = "data5";
    };

    "/mnt/data6" = {
      device = "/dev/disk/by-id/ata-WDC_WD40EURX-64WRWY0_WD-WCC4E2036120";
      fsType = "ext4";
      label  = "data6";
    };

    "/mnt/data7" = {
      device = "/dev/disk/by-id/ata-WDC_WD40EURX-64WRWY0_WD-WCC4E2056001";
      fsType = "ext4";
      label  = "data7";
    };

    "/mnt/tank" = {
      device  = "/mnt/data*";
      fsType  = "fuse.mergerfs";
      options = [
        "defaults"
        "minfreespace=50G"
        "moveonenospc"
        "ignorepponrename"
        "category.create=mfs"
        "func.getattr=newest"
        "fsname=tank"
      ];
    };
  };

  snapraid = {
    enable = true;

    extraConfig = ''
      autosave 500
    '';

    parityFiles = [
      "/mnt/parity0/snapraid.parity"
      "/mnt/parity1/snapraid.parity"
    ];

    contentFiles = [
      "/mnt/data0/snapraid.content"
      "/mnt/data1/snapraid.content"
      "/mnt/data2/snapraid.content"
    ];

    dataDisks = {
      d0 = "/mnt/data0";
      d1 = "/mnt/data1";
      d2 = "/mnt/data2";
      d3 = "/mnt/data3";
      d4 = "/mnt/data4";
      d5 = "/mnt/data5";
      d6 = "/mnt/data6";
      d7 = "/mnt/data7";
    };

    exclude = [
      "*.part"
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
      ".smbdelete*"
    ];

    scrub = {
      interval  = "04:00";
      plan      = 12;
      olderThan = 10;
    };
  };
}