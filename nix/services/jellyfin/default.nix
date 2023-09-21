{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/jellyfin";
in
{
  virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "linuxserver/jellyfin:${vars.services.jellyfin.version}";
      environment = {
        DOCKER_MODS = "linuxserver/mods:jellyfin-opencl-intel";
        PUID = "1000";
        PGID = "100";
        TZ = "America/New_York";
        #UMASK = "002";
      };
      volumes = [
        "/mnt/tank/media/tv:/media/tv:ro"
        "/mnt/tank/media/movies:/media/movies:ro"
        "/mnt/app-data/jellyfin/config:/config"
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri"
        "--network=services"
        "--ip=${vars.services.jellyfin.ip}"
      ];
    };
  };

  systemd.services.docker-jellyfin = {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}
