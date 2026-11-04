{ config, ... }:
let
  svc = config.homelab.services.mongo;
in
{
  homelab.services.mongo = {
    image       = "mongo";
    version     = "8.0.34";
    ip          = "192.168.20.225";
    uid         = 984;
    environment = {
      TZ = "America/New_York";
    };
    volumes     = [
      "${svc.appPath}/data:/data/db"
    ];
  };
}
