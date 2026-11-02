{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.influxdb;
in
{
  homelab.services.influxdb = {
    inherit (vars.services.influxdb) image version ip uid;
    caddyHost = "influx.fatsch.us";
    caddyPort = 8086;
    caddyCors = true;
    volumes = [
      "${svc.appPath}/data:/var/lib/influxdb2"
      "${svc.appPath}/config:/etc/influxdb2"
    ];
  };
}
