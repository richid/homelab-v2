{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.prowlarr;
in
{
  homelab.services.prowlarr = {
    inherit (vars.services.prowlarr) image version ip uid;
    uidEnv      = true;
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
