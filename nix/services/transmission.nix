{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.transmission;
in
{
  homelab.services.transmission = {
    inherit (vars.services.transmission) image version ip uid;
    uidEnv      = true;
    group       = "media";
    caddyHost   = "transmission.fatsch.us";
    caddyCors   = true;
    environment = {
      TRANSMISSION_WEB_HOME = "/config/ui/flood-for-transmission";
      TZ                    = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/config"
      "${svc.appPath}/torrents:/watch"
      "/mnt/tank/Downloads/:/downloads"
    ];
  };
}
