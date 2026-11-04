{ config, ... }:
let
  svc = config.homelab.services.influxdb;
in
{
  homelab.services.influxdb = {
    image       = "influxdb";
    version     = "2.9.1";
    ip          = "192.168.20.228";
    uid         = 970;
    caddyHost   = "influx.fatsch.us";
    caddyPort   = 8086;
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes     = [
      "${svc.appPath}/data:/var/lib/influxdb2"
      "${svc.appPath}/config:/etc/influxdb2"
    ];
  };
}
