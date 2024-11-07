{ config, pkgs, lib, ... }:
let
  vars     = import ../variables.nix;
  appPath = "${vars.services.rootPath}/radarr";
in
{
  virtualisation.oci-containers.containers = {
    radarr = {
      image = "lscr.io/linuxserver/radarr:${vars.services.radarr.version}";
      environment = {
        PUID = toString vars.services.radarr.uid;
        PGID = toString vars.services.media_gid;
        TZ   = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/config"
        "/mnt/tank:/tank"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.radarr.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@radarr=host radarr.fatsch.us"
        "--label=caddy.handle=@radarr"
        "--label=caddy.handle.reverse_proxy={{upstreams}}"
        "--label=caddy.handle.import=cors"
      ];
    };
  };

  systemd.services.docker-radarr = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
