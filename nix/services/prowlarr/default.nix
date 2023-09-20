{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/prowlarr";
in
{
  virtualisation.oci-containers.containers = {
    prowlarr = {
      image = "linuxserver/prowlarr:${vars.services.prowlarr.version}";
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "America/New_York";
      };
      volumes = [
        "${app_path}/config:/config"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.prowlarr.ip}"
      ];
    };
  };

  systemd.services.docker-prowlarr = {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}
