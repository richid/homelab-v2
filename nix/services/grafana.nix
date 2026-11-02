{ config, ... }:
let
  svc = config.homelab.services.grafana;
in
{
  homelab.services.grafana = {
    image       = "grafana/grafana";
    version     = "13.3.0";
    ip          = "192.168.20.226";
    uid         = 971;
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
