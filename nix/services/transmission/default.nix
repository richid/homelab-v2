{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/transmission";
in
{
  virtualisation.oci-containers.containers = {
    transmission = {
      image = "linuxserver/transmission:${vars.services.transmission.version}";
      environment = {
        PUID = "1000";
        PGID = "100";
        TRANSMISSION_WEB_HOME = "/config/ui/flood-for-transmission";
        TZ = "America/New_York";
      };
      volumes = [
        "${app_path}/config:/config"
        "${app_path}/torrents:/watch"
        "/mnt/tank/downloads/:/downloads"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.transmission.ip}"
      ];
    };
  };

  systemd.services.docker-transmission = {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}