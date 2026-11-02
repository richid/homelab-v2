{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.smokeping;
in
{
  homelab.services.smokeping = {
    inherit (vars.services.smokeping) image version ip uid;
    uidEnv      = true;
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
