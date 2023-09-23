{ config, pkgs, lib, ... }:
let
  vars    = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/gotify";
in
{
  virtualisation.oci-containers.containers = {
    gotify = {
      image = "ghcr.io/gotify/server:${vars.services.gotify.version}";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "${appPath}/data:/app/data"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.gotify.ip}"
      ];
    };
  };

  systemd.services.docker-gotify = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}