{ config, ... }:
let
  svc = config.homelab.services.sonarr;
in
{
  homelab.services.sonarr = {
    image       = "lscr.io/linuxserver/sonarr";
    version     = "4.0.20";
    ip          = "192.168.20.221";
    uid         = 981;
    uidMode     = "env";
    group       = "media";
    caddyHost   = "sonarr.fatsch.us";
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/config"
      "/mnt/tank:/tank"
    ];
  };
}
