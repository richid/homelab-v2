{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/smokeping";
in
{
  virtualisation.oci-containers.containers = {
    scrutiny = {
      image = "lscr.io/linuxserver/smokeping:latest";
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Etc/UTC";
      };
      ports = [
        "80:80"
      ];
      volumes = [
        "${app_path}/config:/config"
        "${app_path}/data:/data"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.ips.smokeping}"
      ];
    };
  };

  systemd.services.docker-smokeping = {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}