{ config, ... }:
let
  svc = config.homelab.services.transmission;
in
{
  homelab.services.transmission = {
    image       = "lscr.io/linuxserver/transmission";
    version     = "4.1.4";
    ip          = "192.168.20.216";
    uid         = 990;
    uidMode     = "env";
    group       = "media";
    caddyHost   = "transmission.fatsch.us";
    caddyCors   = true;
    environment = {
      TRANSMISSION_WEB_HOME = "/config/ui/flood-for-transmission";
      TZ                    = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/config"
      "${svc.appPath}/torrents:/watch"
      "/mnt/tank/Downloads/:/downloads"
    ];
  };
}
