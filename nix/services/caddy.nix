{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.caddy;
in
{
  homelab.services.caddy = {
    inherit (vars.services.caddy) image version ip;
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
