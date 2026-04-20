{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  secrets = import ../secrets.nix;
  appPath = "${vars.services.rootPath}/trackage";
in
{
  virtualisation.oci-containers.containers = {
    trackage = {
      image = "ghcr.io/richid/trackage:${vars.services.trackage.version}";
      user  = "${toString vars.services.trackage.uid}:${toString vars.services.base_gid}";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/config"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.trackage.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@trackage=host trackage.fatsch.us"
        "--label=caddy.handle=@trackage"
        "--label=caddy.handle.reverse_proxy={{upstreams 3000}}"
        "--label=caddy.handle.import=cors"
        "--label=diun.include_tags=^\\d+\\.\\d+\\.\\d+$"
      ];
    };
  };

  systemd.services.docker-trackage = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}