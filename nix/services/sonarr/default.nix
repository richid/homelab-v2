{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/sonarr";
in
{
  virtualisation.oci-containers.containers = {
    sonarr = {
      image = "linuxserver/sonarr:${vars.services.sonarr.version}";
      environment = {
        PUID = toString vars.services.sonarr.uid;
        PGID = toString vars.services.media_gid;
        TZ   = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/config"
        "/mnt/tank:/tank"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.sonarr.ip}"
      ];
    };
  };

  systemd.services.docker-sonarr = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
