{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.syncthing;
in
{
  homelab.services.syncthing = {
    inherit (vars.services.syncthing) image version ip uid;
    uidEnv      = true;
    group       = "family";
    appPath     = "/mnt/dozer/Sync";
    caddyHost   = "files.fatsch.us";
    caddyPort   = 8384;
    caddyCors   = true;
    environment = {
      PCAP = "cap_chown,cap_fowner+ep";
      TZ   = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/config"
      "${svc.appPath}/data:/data"
    ];
  };
}
