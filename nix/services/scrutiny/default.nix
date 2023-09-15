{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/scrutiny";
in
{
  virtualisation.oci-containers.containers = {
    smokeping = {
      image = "ghcr.io/analogj/scrutiny:master-omnibus";
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
        "--network=services"
        "--ip=${vars.services.ips.scrutiny}"
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