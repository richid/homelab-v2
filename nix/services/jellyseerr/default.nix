{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/jellyseerr";
in
{
  virtualisation.oci-containers.containers = {
    jellyseerr = {
      image = "fallenbagel/jellyseerr:${vars.services.jellyseerr.version}";
      user = "${toString vars.services.jellyseerr.uid}:${toString vars.services.base_gid}";
      environment = {
        PORT = "80";
        TZ   = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/app/config"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.jellyseerr.ip}"
      ];
    };
  };

  systemd.services.docker-jellyseerr = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
