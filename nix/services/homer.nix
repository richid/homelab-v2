{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "${vars.services.rootPath}/homer";
in
{
  virtualisation.oci-containers.containers = {
    homer = {
      image = "b4bz/homer:${vars.services.homer.version}";
      user  = "${toString vars.services.homer.uid}:${toString vars.services.base_gid}";
      environment = {
        PORT = "80";
        TZ   = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/www/assets"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.homer.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@home=host home.fatsch.us"
        "--label=caddy.handle=@home"
        "--label=caddy.handle.reverse_proxy={{upstreams}}"
        "--label=diun.include_tags=^v\\d+\\.\\d+\\.\\d+$"
      ];
    };
  };

  systemd.services.docker-homer = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}