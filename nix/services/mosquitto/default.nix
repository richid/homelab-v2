{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/mosquitto";
in
{
  virtualisation.oci-containers.containers = {
    mosquitto = {
      image = "eclipse-mosquitto:${vars.services.mosquitto.version}";
      user = "${toString vars.services.mosquitto.uid}:${toString vars.services.base_gid}";
      volumes = [
        "${appPath}/config/mosquitto.conf:/mosquitto/config/mosquitto.conf"
        "${appPath}/data:/mosquitto/data"
        "${appPath}/log:/mosquitto/log"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.mosquitto.ip}"
      ];
    };
  };

  systemd.services.docker-mosquitto = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}