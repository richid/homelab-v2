{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.mongo;
in
{
  homelab.services.mongo = {
    inherit (vars.services.mongo) image version ip uid;
    volumes = [
      "${svc.appPath}/v4.4/data:/data/db"
    ];
    extraOptions = [
      "--pull=always"
    ];
  };
}
