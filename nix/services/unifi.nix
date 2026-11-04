{ config, ... }:
let
  svc = config.homelab.services.unifi;
in
{
  homelab.services.unifi = {
    image       = "lscr.io/linuxserver/unifi-network-application";
    version     = "10.6.109";
    ip          = "192.168.10.10";
    uid         = 975;
    uidMode     = "env";
    network     = "mgmt";
    environment = {
      MEM_LIMIT    = "4096";
      MEM_STARTUP  = "4096";
      MONGO_USER   = "unifi";
      MONGO_HOST   = "mongo.fatsch.us";
      MONGO_PORT   = "27017";
      MONGO_DBNAME = "unifi";
      TZ           = "America/New_York";
    };
    environmentFiles = [ config.age.secrets.unifi.path ];
    volumes = [
      "${svc.appPath}/config:/config"
    ];
    extraOptions = [
      "--stop-timeout=60"
    ];
  };
}
