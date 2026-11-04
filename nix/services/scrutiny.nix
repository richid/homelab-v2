{ config, ... }:
let
  svc = config.homelab.services.scrutiny;
  disks = [
    { name = "sda"; id = "ata-ST10000NM0016-1TT101_ZA21BXT1"; }
    { name = "sdb"; id = "ata-ST10000NM0016-1TT101_ZA218QZ0"; }
    { name = "sdc"; id = "ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K1CZK8JC"; }
    { name = "sdd"; id = "ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K2JYLLHL"; }
    { name = "sde"; id = "ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K2LD2NTR"; }
    { name = "sdf"; id = "ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K4FEACY1"; }
    { name = "sdg"; id = "ata-WDC_WD40EURX-64WRWY0_WD-WCC4E2056001"; }
    { name = "sdh"; id = "ata-WDC_WD40EURX-64WRWY0_WD-WCC4E1745891"; }
    { name = "sdi"; id = "ata-WDC_WD40EURX-64WRWY0_WD-WCC4E2036120"; }
    { name = "sdj"; id = "ata-ST3500630AS_9QG1ATWD"; }
    { name = "sdk"; id = "ata-HUH721010ALE601_7PK1UM0G"; }
    { name = "sdl"; id = "ata-ST3500630AS_9QG1ATEN"; }
    { name = "sdm"; id = "ata-ST3500630AS_9QG1BZDG"; }
    { name = "sdn"; id = "ata-ST3500630AS_9QG1C94E"; }
  ];
in
{
  homelab.services.scrutiny = {
    image       = "ghcr.io/analogj/scrutiny";
    version     = "v0.10.0-omnibus";
    ip          = "192.168.20.210";
    caddyHost   = "disks.fatsch.us";
    caddyPort   = 8080;
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes     = [
      "${svc.appPath}/config:/opt/scrutiny/config"
      "${svc.appPath}/influxdb:/opt/scrutiny/influxdb"
      "/run/udev:/run/udev:ro"
    ];
    preOptions = [
      "--cap-add=SYS_ADMIN"
      "--cap-add=SYS_RAWIO"
      "--device=/dev/nvme0"
      "--device=/dev/nvme1"
      "--device=/dev/nvme2"
    ] ++ map (d: "--device=/dev/disk/by-id/${d.id}:/dev/${d.name}") disks;
  };
}
