{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.jellyfin;
in
{
  homelab.services.jellyfin = {
    inherit (vars.services.jellyfin) image version ip uid;
    uidEnv       = true;
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
  };
}
