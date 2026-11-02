{ config, ... }:
let
  svc = config.homelab.services.audiobookshelf;
in
{
  homelab.services.audiobookshelf = {
    image       = "ghcr.io/advplyr/audiobookshelf";
    version     = "2.37.2";
    ip          = "192.168.20.234";
    uid         = 965;
    group       = "media";
    caddyHost   = "books.fatsch.us";
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "/mnt/tank/Media/Books:/audiobooks"
      "${svc.appPath}/podcasts:/podcasts"
      "${svc.appPath}/config:/config"
      "${svc.appPath}/metadata:/metadata"
    ];
  };
}
