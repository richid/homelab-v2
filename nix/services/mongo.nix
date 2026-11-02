{ config, ... }:
let
  svc = config.homelab.services.mongo;
in
{
  homelab.services.mongo = {
    image   = "mongo";
    version = "7.0.45";
    ip      = "192.168.20.225";
    uid     = 984;
    volumes = [
      "${svc.appPath}/data:/data/db"
    ];
    extraOptions = [
      "--pull=always"
    ];
  };
}
