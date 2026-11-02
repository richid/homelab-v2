{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.unifi;
in
{
  homelab.services.unifi = {
    inherit (vars.services.unifi) image version ip uid;
    uidEnv      = true;
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
  };
}
