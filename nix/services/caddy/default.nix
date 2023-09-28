{ config, pkgs, lib, ... }:
let
  vars    = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/caddy";
in
{
  virtualisation.oci-containers.containers = {
    caddy = {
      image = "caddy:${vars.services.caddy.version}";
      user  = "${toString vars.services.caddy.uid}:${toString vars.services.base_gid}";
      environment = {
        TZ = "America/New_York";
      };
      ports = [
        "443:443"
      ];
      volumes = [
        "${appPath}/data:/data"
        "${appPath}/config:/config"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.caddy.ip}"
      ];
    };
  };

  systemd.services.docker-caddy = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}