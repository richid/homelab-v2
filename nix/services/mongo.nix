{ config, ... }:
let
  svc = config.homelab.services.mongo;
in
{
  homelab.services.mongo = {
    image   = "mongo";
    version = "4.4.30";
    ip      = "192.168.20.225";
    uid     = 984;
    volumes = [
      "${svc.appPath}/v4.4/data:/data/db"
    ];
    extraOptions = [
      "--pull=always"
    ];
  };
}
