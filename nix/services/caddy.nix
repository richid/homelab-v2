{ config, ... }:
let
  svc = config.homelab.services.caddy;
in
{
  homelab.services.caddy = {
    image       = "ghcr.io/richid/caddy-docker-proxy-r53-dns";
    version     = "2.8.4";
    ip          = "192.168.20.200";
    uid         = 977;
    uidMode     = "none";
    environment = {
      CADDY_DOCKER_CADDYFILE_PATH = "/etc/caddy/Caddyfile";
      TZ                          = "America/New_York";
    };
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "${svc.appPath}/Caddyfile:/etc/caddy/Caddyfile"
      "${svc.appPath}/config:/config"
      "${svc.appPath}/data:/data"
    ];
  };
}
