{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.sonarr;
in
{
  homelab.services.sonarr = {
    inherit (vars.services.sonarr) image version ip uid;
    uidEnv      = true;
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
