{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.audiobookshelf;
in
{
  homelab.services.audiobookshelf = {
    inherit (vars.services.audiobookshelf) image version ip uid;
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
