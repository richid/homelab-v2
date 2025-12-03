{ config, pkgs, lib, ... }:
let
  vars     = import ../variables.nix;
  appPath = "${vars.services.rootPath}/tunarr";
in
{
  virtualisation.oci-containers.containers = {
    tunarr = {
      image = "ghcr.io/chrisbenincasa/tunarr:${vars.services.tunarr.version}";
      user  = "${toString vars.services.tunarr.uid}:${toString vars.services.media_gid}";
      environment = {
        TUNARR_SERVER_ADMIN_MODE = "true";
        LOG_LEVEL = "debug";
        TZ = "America/New_York";
      };
      volumes = [
        "${appPath}/data:/config/tunarr"
        "${appPath}/streams:/streams"
        "${appPath}/root:/root"
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri"
        "--network=services"
        "--ip=${vars.services.tunarr.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@tunarr=host tunarr.fatsch.us"
        "--label=caddy.handle=@tunarr"
        "--label=caddy.handle.reverse_proxy={{upstreams 8000}}"
        "--label=caddy.handle.import=cors"
      ];
    };
  };

  systemd.services.docker-tunarr = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}