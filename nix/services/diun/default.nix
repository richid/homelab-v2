{ config, pkgs, lib, ... }:
let
  vars    = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/diun";
in
{
  virtualisation.oci-containers.containers = {
    diun = {
      image = "crazymax/diun:${vars.services.diun.version}";
      environment = {
        TZ                                   = "America/New_York";
        #DIUN_DEFAULTS_WATCHREPO              = "true";
        DIUN_WATCH_SCHEDULE                  = "0 */12 * * *";
        DIUN_PROVIDERS_DOCKER                = "true";
        DIUN_PROVIDERS_DOCKER_WATCHBYDEFAULT = "true";
        DIUN_NOTIF_GOTIFY_ENDPOINT           = "http://gotify.schu";
        DIUN_NOTIF_GOTIFY_TOKEN              = "ArX72kXzIz0rVcF"; # Regenerate and encrypt this token
        DIUN_NOTIF_GOTIFY_PRIORITY           = "3";
      };
      volumes = [
        "${appPath}/data:/data"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.diun.ip}"
      ];
    };
  };

  systemd.services.docker-diun = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}