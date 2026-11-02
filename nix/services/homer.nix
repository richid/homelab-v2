{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.homer;
in
{
  homelab.services.homer = {
    inherit (vars.services.homer) image version ip uid;
    caddyHost   = "home.fatsch.us";
    environment = {
      PORT = "80";
      TZ   = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/www/assets"
    ];
  };
}
