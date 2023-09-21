{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/watchstate";
in
{
  virtualisation.oci-containers.containers = {
    watchstate = {
      image = "ghcr.io/arabcoders/watchstate:${vars.services.watchstate.version}";
      environment = {
        WS_CRON_IMPORT = "1";
        WS_TZ = "America/New_York";
      };
      volumes = [
        "${app_path}/config:/config"
      ];
      extraOptions = [
        "--user=1000:100"
        "--network=services"
        "--ip=${vars.services.watchstate.ip}"
      ];
    };
  };

  systemd.services.docker-watchstate = {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}