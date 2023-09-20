{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/watchtower";
in
{
  virtualisation.oci-containers.containers = {
    watchtower = {
      image = "containrrr/watchtower:${vars.services.watchtower.version}";
      environment = {
        TZ                                   = "America/New_York";
        WATCHTOWER_MONITOR_ONLY              = "true";
        WATCHTOWER_NOTIFICATIONS             = "gotify";
        WATCHTOWER_NOTIFICATION_GOTIFY_URL   = "http://${vars.services.gotify.ip}";
        WATCHTOWER_NOTIFICATION_GOTIFY_TOKEN = "ArX72kXzIz0rVcF"; # Regenerate and encrypt this token
      };
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.watchtower.ip}"
      ];
    };
  };

  # TODO: I don't think this needs any volumes, so delete the ZFS dataset and remove this dep
  systemd.services.docker-watchtower = {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}