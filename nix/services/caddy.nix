{ config, ... }:
let
  svc = config.homelab.services.caddy;
in
{
  age.secrets.caddy.file = ../../secrets/caddy.env.age;

  homelab.services.caddy = {
    image            = "ghcr.io/richid/caddy-docker-proxy-r53-dns";
    version          = "2.11.9";
    ip               = "192.168.20.200";
    uid              = 977;
    uidMode          = "none";
    environment      = {
      CADDY_DOCKER_CADDYFILE_PATH = "/etc/caddy/Caddyfile";
      TZ                          = "America/New_York";
    };
    environmentFiles = [ config.age.secrets.caddy.path ];
    volumes          = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "${./caddy/Caddyfile}:/etc/caddy/Caddyfile:ro"
      "${svc.appPath}/config:/config"
      "${svc.appPath}/data:/data"
      "${./caddy/404.html}:/srv/404/404.html:ro"
    ];
    extraOptions     = [
      "--label=caddy=*.fatsch.us"
      "--label=caddy.handle.root=* /srv/404"
      "--label=caddy.handle.rewrite=* /404.html"
      "--label=caddy.handle.file_server.status=404"
    ];
  };
}
