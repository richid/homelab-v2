{ config, ... }:
let
  svc = config.homelab.services.tunarr;
in
{
  homelab.services.tunarr = {
    image       = "ghcr.io/chrisbenincasa/tunarr";
    version     = "1.3.15";
    ip          = "192.168.20.235";
    uid         = 964;
    group       = "media";
    caddyHost   = "tunarr.fatsch.us";
    caddyPort   = 8000;
    caddyCors   = true;
    environment = {
      TUNARR_SERVER_ADMIN_MODE = "true";
      LOG_LEVEL                = "debug";
      MEILI_DUMP_DIR           = "/config/tunarr/ms-dumps";
      TZ                       = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/data:/config/tunarr"
      "${svc.appPath}/streams:/streams"
      "${svc.appPath}/root:/root"
    ];
    preOptions = [
      "--device=/dev/dri:/dev/dri"
    ];
  };
}
