{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.gotify;
in
{
  homelab.services.gotify = {
    inherit (vars.services.gotify) image version ip uid;
    caddyHost     = "gotify.fatsch.us";
    caddyHeaderUp = "-Origin";
    caddyCors     = true;
    environment   = {
      TZ = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/data:/app/data"
    ];
  };
}
