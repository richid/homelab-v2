{ config, ... }:
let
  svc = config.homelab.services.syncthing;
in
{
  homelab.services.syncthing = {
    image       = "lscr.io/linuxserver/syncthing";
    version     = "2.1.7";
    ip          = "192.168.20.236";
    uid         = 1000; # rich;
    uidMode     = "env";
    group       = "family";
    createUser  = false;
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
