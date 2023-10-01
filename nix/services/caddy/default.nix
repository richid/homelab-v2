{ config, pkgs, lib, ... }:
let
  vars    = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/caddy";
in
{
  virtualisation.oci-containers.containers = {
    caddy = {
      image = "lucaslorentz/caddy-docker-proxy:${vars.services.caddy.version}";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "${appPath}/data:/data"
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