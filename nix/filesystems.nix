{
    ##securityType = "user";
    #extraConfig = ''
    #  workgroup = WORKGROUP
    #  server string = smbnix
    #  netbios name = smbnix
    #  security = user
    #  #use sendfile = yes
    #  #max protocol = smb2
    #  # note: localhost is the ipv6 localhost ::1
    #  hosts allow = 192.168.0. 127.0.0.1 localhost
    #  hosts deny = 0.0.0.0/0
    #  guest account = nobody
    #  map to guest = bad user
    #'';
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
      media = {
        path = "/mnt/tank/media";
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
      "/mnt/parity0/snapraid.content" # Temp to get around the N+1 req for content files
      "/mnt/parity1/snapraid.content" # Temp to get around the N+1 req for content files
      "/mnt/data0/snapraid.content"
    ];
    dataDisks = {
      d1 = "/mnt/data0";
    };
    exclude = [
      "*.part"
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
    ];
  };
}