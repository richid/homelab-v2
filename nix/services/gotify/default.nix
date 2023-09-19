{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/gotify";
in
{
  virtualisation.oci-containers.containers = {
    gotify = {
      image = "ghcr.io/gotify/server:${vars.services.gotify.version}";
      environment = {
        TZ = "America/New_York";
      };
      ports = [
        "80:80"
      ];
      volumes = [
        "${app_path}/data:/app/data"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.gotify.ip}"
      ];
    };
  };

  systemd.services.docker-gotify = {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}