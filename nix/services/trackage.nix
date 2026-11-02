{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.trackage;
in
{
  homelab.services.trackage = {
    inherit (vars.services.trackage) image version ip uid;
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
