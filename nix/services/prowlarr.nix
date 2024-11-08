{ config, pkgs, lib, ... }:
let
  vars     = import ../variables.nix;
  appPath = "${vars.services.rootPath}/prowlarr";
in
{
  virtualisation.oci-containers.containers = {
    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:${vars.services.prowlarr.version}";
      environment = {
        PUID = toString vars.services.prowlarr.uid;
        PGID = toString vars.services.base_gid;
        TZ   = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/config"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.prowlarr.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@prowlarr=host prowlarr.fatsch.us"
        "--label=caddy.handle=@prowlarr"
        "--label=caddy.handle.reverse_proxy={{upstreams}}"
        "--label=caddy.handle.import=cors"
        "--label=diun.include_tags=^\\d+\\.\\d+\\.\\d+$"
      ];
    };
  };

  systemd.services.docker-prowlarr = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
