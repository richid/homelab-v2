{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/watchstate";
in
{
  virtualisation.oci-containers.containers = {
    watchstate = {
      image = "ghcr.io/arabcoders/watchstate:${vars.services.watchstate.version}";
      user = "${toString vars.services.watchstate.uid}:${toString vars.services.base_gid}";
      environment = {
        WS_CRON_EXPORT = "1";
        WS_CRON_IMPORT = "1";
        WS_TZ          = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/config"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.watchstate.ip}"
      ];
    };
  };

  systemd.services.docker-watchstate = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}