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
        "--cap-add=SYS_RAWIO"
        "--device=/dev/nvme0"
        "--device=/dev/nvme1"
        "--device=/dev/nvme2"
        "--device=/dev/sda"
        "--device=/dev/sdb"
        "--device=/dev/sdc"
        "--network=services"
        "--ip=${vars.services.scrutiny.ip}"
        "--privileged"
        "--label=caddy=disks.schu"
        "--label=caddy.reverse_proxy={{upstreams}}"
        "--label=caddy.tls=internal"
      ];
    };
  };

  systemd.services.docker-scrutiny= {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}