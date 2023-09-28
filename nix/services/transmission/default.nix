{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/transmission";
in
{
  virtualisation.oci-containers.containers = {
    transmission = {
      image = "lscr.io/linuxserver/transmission:${vars.services.transmission.version}";
      environment = {
        PUID = toString vars.services.transmission.uid;
        PGID = toString vars.services.media_gid;
        TRANSMISSION_WEB_HOME = "/config/ui/flood-for-transmission";
        TZ = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/config"
        "${appPath}/torrents:/watch"
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
      RequiresMountsFor = appPath;
    };
  };
}