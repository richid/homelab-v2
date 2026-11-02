{ config, ... }:
let
  svc = config.homelab.services.trackage;
in
{
  homelab.services.trackage = {
    image       = "ghcr.io/richid/trackage";
    version     = "0.4.0";
    ip          = "192.168.20.237";
    uid         = 961;
    caddyHost   = "trackage.fatsch.us";
    caddyPort   = 3000;
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/config"
    ];
  };
}
