{ config, ... }:
let
  svc = config.homelab.services.prowlarr;
in
{
  homelab.services.prowlarr = {
    image       = "lscr.io/linuxserver/prowlarr";
    version     = "2.7.0";
    ip          = "192.168.20.217";
    uid         = 989;
    uidMode     = "env";
    caddyHost   = "prowlarr.fatsch.us";
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/config"
    ];
  };
}
