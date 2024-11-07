{ config, pkgs, lib, ... }:
let
  vars     = import ../variables.nix;
  appPath = "${vars.services.rootPath}/audiobookshelf";
in
{
  virtualisation.oci-containers.containers = {
    audiobookshelf = {
      image = "ghcr.io/advplyr/audiobookshelf:${vars.services.audiobookshelf.version}";
      user  = "${toString vars.services.audiobookshelf.uid}:${toString vars.services.media_gid}";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "/mnt/tank/Media/Books:/audiobooks"
        "${appPath}/podcasts:/podcasts"
        "${appPath}/config:/config"
        "${appPath}/metadata:/metadata"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.audiobookshelf.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@books=host books.fatsch.us"
        "--label=caddy.handle=@books"
        "--label=caddy.handle.reverse_proxy={{upstreams}}"
        "--label=caddy.handle.import=cors"
        "--label=diun.include_tags=^\\d+\\.\\d+\\.\\d+$"
      ];
    };
  };

  systemd.services.docker-audiobookshelf = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
