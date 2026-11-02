{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.mosquitto;
in
{
  homelab.services.mosquitto = {
    inherit (vars.services.mosquitto) image version ip uid;
    volumes = [
      "${svc.appPath}/config/mosquitto.conf:/mosquitto/config/mosquitto.conf"
      "${svc.appPath}/data:/mosquitto/data"
      "${svc.appPath}/log:/mosquitto/log"
    ];
  };
}
