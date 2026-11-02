{ config, ... }:
let
  svc = config.homelab.services.smokeping;
in
{
  homelab.services.smokeping = {
    image       = "lscr.io/linuxserver/smokeping";
    version     = "2.9.0";
    ip          = "192.168.20.211";
    uid         = 993;
    uidMode     = "env";
    caddyHost   = "smokeping.fatsch.us";
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/config"
      "${svc.appPath}/data:/data"
    ];
  };
}
