{ config, pkgs, lib, ... }:
let
  vars     = import ../variables.nix;
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
        "/mnt/tank/Media:/media:ro"
        "${appPath}/config:/config"
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri"
        "--network=services"
        "--ip=${vars.services.jellyfin.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@jellyfin=host jellyfin.fatsch.us watch.fatsch.us"
        "--label=caddy.handle=@jellyfin"
        "--label=caddy.handle.reverse_proxy={{upstreams}}"
        "--label=caddy.handle.import=cors"
        "--label=diun.include_tags=^v\\d+\\.\\d+\\.\\d+-omnibus$"
      ];
    };
  };

  systemd.services.docker-jellyfin = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
