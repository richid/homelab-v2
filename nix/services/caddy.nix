{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "${vars.services.rootPath}/caddy";
in
{
  virtualisation.oci-containers.containers = {
    caddy = {
      image = "ghcr.io/richid/caddy-docker-proxy-r53-dns:${vars.services.caddy.version}";
      environment = {
        CADDY_DOCKER_CADDYFILE_PATH = "/etc/caddy/Caddyfile";
        TZ = "America/New_York";
      };
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "${appPath}/Caddyfile:/etc/caddy/Caddyfile"
        "${appPath}/config:/config"
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