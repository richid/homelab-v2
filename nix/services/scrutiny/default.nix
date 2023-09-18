{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/scrutiny";
in
{
  virtualisation.oci-containers.containers = {
    scrutiny = {
      image = "ghcr.io/analogj/scrutiny:${vars.services.scrutiny.version}";
      ports = [
        "1080:1080"
        "80:8080"
      ];
      volumes = [
        "${app_path}/config:/opt/scrutiny/config"
        "${app_path}/influxdb:/opt/scrutiny/influxdb"
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
      ];
    };
  };

  systemd.services.docker-scrutiny= {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}