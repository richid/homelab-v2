{ config, pkgs, lib, ... }:
let
  vars     = import ../variables.nix;
  appPath = "/mnt/dozer/Sync";
in
{
  virtualisation.oci-containers.containers = {
    syncthing = {
      image = "lscr.io/linuxserver/syncthing:${vars.services.syncthing.version}";
      environment = {
        PCAP = "cap_chown,cap_fowner+ep";
        PUID = toString vars.services.syncthing.uid;
        PGID = toString vars.services.family_gid;
        TZ   = "America/New_York";
      };
      volumes = [
        "${appPath}/config:/config"
        "${appPath}/data:/data"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.syncthing.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@files=host files.fatsch.us"
        "--label=caddy.handle=@files"
        "--label=caddy.handle.reverse_proxy={{upstreams 8384}}"
        "--label=caddy.handle.import=cors"
        "--label=diun.include_tags=^v\\d+\\.\\d+\\.\\d+-(\.*)$"
      ];
    };
  };

  systemd.services.docker-syncthing = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}