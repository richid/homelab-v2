{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/scrutiny";
in
{
  virtualisation.oci-containers.containers = {
    scrutiny = {
      image = "ghcr.io/analogj/scrutiny:${vars.services.scrutiny.version}";
      volumes = [
        "${appPath}/config:/opt/scrutiny/config"
        "${appPath}/influxdb:/opt/scrutiny/influxdb"
        "/run/udev:/run/udev:ro"
      ];
      extraOptions = [
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
        "--device=/dev/sdo"
        "--network=services"
        "--ip=${vars.services.scrutiny.ip}"
        "--label=caddy=disks.schu"
        "--label=caddy.reverse_proxy={{upstreams 8080}}"
        "--label=caddy.tls=internal"
        "--label=caddy.import=cors"
        "--label=diun.include_tags=^v\\d+\\.\\d+\\.\\d+-omnibus$"
      ];
    };
  };

  systemd.services.docker-scrutiny= {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
