{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.scrutiny;
in
{
  homelab.services.scrutiny = {
    inherit (vars.services.scrutiny) image version ip;
    caddyHost = "disks.fatsch.us";
    caddyPort = 8080;
    caddyCors = true;
    volumes   = [
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
      "--device=/dev/sda"
      "--device=/dev/sdb"
      "--device=/dev/sdd"
      "--device=/dev/sde"
      "--device=/dev/sdf"
      "--device=/dev/sdg"
      "--device=/dev/sdh"
      "--device=/dev/sdi"
      "--device=/dev/sdj"
      "--device=/dev/sdk"
      "--device=/dev/sdl"
      "--device=/dev/sdm"
      "--device=/dev/sdn"
    ];
  };
}
