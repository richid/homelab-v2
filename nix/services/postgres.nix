{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.postgres16;
in
{
  homelab.services.postgres16 = {
    inherit (vars.services.postgres16) image version ip uid;
    appPath     = "${vars.services.rootPath}/postgres";
    environment = {
      POSTGRES_PASSWORD = "postgres";
      POSTGRES_USER     = "postgres";
      TZ                = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/v16/data:/var/lib/postgresql/data"
    ];
  };
}
