{ config, ... }:
let
  svc = config.homelab.services.radarr;
in
{
  homelab.services.radarr = {
    image       = "lscr.io/linuxserver/radarr";
    version     = "6.4.4";
    ip          = "192.168.20.220";
    uid         = 982;
    uidMode     = "env";
    group       = "media";
    caddyHost   = "radarr.fatsch.us";
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
