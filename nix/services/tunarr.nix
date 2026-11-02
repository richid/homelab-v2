{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.tunarr;
in
{
  homelab.services.tunarr = {
    inherit (vars.services.tunarr) image version ip uid;
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
