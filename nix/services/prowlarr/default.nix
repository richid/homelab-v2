{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/prowlarr";
in
{
  virtualisation.oci-containers.containers = {
    prowlarr = {
      image = "linuxserver/prowlarr:${vars.services.prowlarr.version}";
      environment = {
        PUID = toString vars.services.prowlarr.uid;
        PGID = toString vars.services.base_gid;
        TZ   = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/config"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.prowlarr.ip}"
      ];
    };
  };

  systemd.services.docker-prowlarr = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
