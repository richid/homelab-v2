{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.grafana;
in
{
  homelab.services.grafana = {
    inherit (vars.services.grafana) image version ip uid;
    caddyHost   = "grafana.fatsch.us";
    caddyPort   = 3000;
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/data:/var/lib/grafana"
    ];
  };
}
