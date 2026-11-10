{ config, ... }:
let
  svc = config.homelab.services.jellyfin;
in
{
  homelab.services.jellyfin = {
    image        = "lscr.io/linuxserver/jellyfin";
    version      = "12.4ubu2604-ls59";
    ip           = "192.168.20.218";
    uid          = 985;
    uidMode      = "env";
    group        = "media";
    caddyHost    = "jellyfin.fatsch.us";
    caddyAliases = [ "watch.fatsch.us" ];
    caddyCors    = true;
    environment  = {
      DOCKER_MODS = "linuxserver/mods:jellyfin-opencl-intel";
      TZ          = "America/New_York";
    };
    volumes = [
      "/mnt/tank/Media:/media:ro"
      "${svc.appPath}/config:/config"
    ];
    preOptions = [
      "--device=/dev/dri:/dev/dri"
    ];
    extraOptions = [
      "--stop-timeout=60"
    ];
  };
}
