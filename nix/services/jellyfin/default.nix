{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/jellyfin";
in
{
  virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "lscr.io/linuxserver/jellyfin:${vars.services.jellyfin.version}";
      environment = {
        DOCKER_MODS = "linuxserver/mods:jellyfin-opencl-intel";
        PUID = toString vars.services.jellyfin.uid;
        PGID = toString vars.services.media_gid;
        TZ = "America/New_York";
      };
      volumes = [
        "/mnt/tank/media:/media:ro"
        "${appPath}/config:/config"
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri"
        "--network=services"
        "--ip=${vars.services.jellyfin.ip}"
        "--label=caddy=watch.schu jellyfin.schu"
        "--label=caddy.reverse_proxy={{upstreams}}"
        "--label=caddy.tls=internal"
      ];
    };
  };

  systemd.services.docker-jellyfin = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
