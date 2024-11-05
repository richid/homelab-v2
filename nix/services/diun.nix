{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "${vars.services.rootPath}/diun";
in
{
  virtualisation.oci-containers.containers = {
    diun = {
      image = "crazymax/diun:${vars.services.diun.version}";
      environment = {
        DIUN_DEFAULTS_INCLUDETAGS            ="^\\d+\\.\\d+\\.\\d+$";
        DIUN_DEFAULTS_MAXTAGS                = "20";
        DIUN_DEFAULTS_NOTIFYON               = "new";
        DIUN_DEFAULTS_SORTTAGS               = "semver";
        DIUN_DEFAULTS_WATCHREPO              = "true";
        DIUN_NOTIF_GOTIFY_ENDPOINT           = "http://${vars.services.gotify.ip}"; # Can't use DNS, certs are self-signed
        DIUN_NOTIF_GOTIFY_PRIORITY           = "3";
        DIUN_NOTIF_GOTIFY_TOKEN              = "ArX72kXzIz0rVcF"; # Regenerate and encrypt this token
        DIUN_PROVIDERS_DOCKER                = "true";
        DIUN_PROVIDERS_DOCKER_WATCHBYDEFAULT = "true";
        DIUN_WATCH_SCHEDULE                  = "0 */12 * * *";
        TZ                                   = "America/New_York";
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