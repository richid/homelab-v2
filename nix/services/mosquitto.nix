{ config, ... }:
let
  svc = config.homelab.services.mosquitto;
in
{
  homelab.services.mosquitto = {
    image       = "eclipse-mosquitto";
    version     = "2.0.22";
    ip          = "192.168.20.212";
    uid         = 988;
    environment = {
      TZ = "America/New_York";
    };
    volumes     = [
      "${./mosquitto/mosquitto.conf}:/mosquitto/config/mosquitto.conf:ro"
      "${svc.appPath}/data:/mosquitto/data"
      "${svc.appPath}/log:/mosquitto/log"
    ];
  };
}
