{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.radarr;
in
{
  homelab.services.radarr = {
    inherit (vars.services.radarr) image version ip uid;
    uidEnv      = true;
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
