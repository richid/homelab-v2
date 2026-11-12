{ config, ... }:
let
  svc = config.homelab.services.jellyseerr;
in
{
  homelab.services.jellyseerr = {
    image        = "ghcr.io/seerr-team/seerr";
    version      = "v3.5.2";
    ip           = "192.168.20.222";
    uid          = 978;
    caddyHost    = "requests.fatsch.us";
    caddyAliases = [ "jellyseerr.fatsch.us" ];
    caddyCors    = true;
    environment  = {
      PORT = "80";
      TZ   = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/app/config"
    ];
    extraOptions = [
      "--init"
    ];
  };
}
