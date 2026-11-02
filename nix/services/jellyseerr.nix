{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.jellyseerr;
in
{
  homelab.services.jellyseerr = {
    inherit (vars.services.jellyseerr) image version ip uid;
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
  };
}
