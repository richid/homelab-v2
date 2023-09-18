{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/mosquitto";
in
{
  virtualisation.oci-containers.containers = {
    mosquitto = {
      image = "eclipse-mosquitto:${vars.services.mosquitto.version}";
      ports = [
        "1883:1883"
        "9001:9001"
      ];
      volumes = [
        "${app_path}/config/mosquitto.conf:/mosquitto/config/mosquitto.conf"
        "${app_path}/data:/mosquitto/data"
        "${app_path}/log:/mosquitto/log"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.mosquitto.ip}"
      ];
    };
  };

  systemd.services.docker-mosquitto = {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}