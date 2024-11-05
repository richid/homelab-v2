{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "${vars.services.rootPath}/smokeping";
in
{
  virtualisation.oci-containers.containers = {
    smokeping = {
      image = "lscr.io/linuxserver/smokeping:${vars.services.smokeping.version}";
      environment = {
        PUID = toString vars.services.smokeping.uid;
        PGID = toString vars.services.base_gid;
        TZ   = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/config"
        "${appPath}/data:/data"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.smokeping.ip}"
        "--label=caddy=smokeping.schu"
        "--label=caddy.reverse_proxy={{upstreams}}"
        "--label=caddy.tls=internal"
        "--label=caddy.import=cors"
      ];
    };
  };

  systemd.services.docker-smokeping = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}