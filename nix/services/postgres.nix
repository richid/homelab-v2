{ config, ... }:
let
  svc = config.homelab.services.postgres16;
in
{
  homelab.services.postgres16 = {
    image       = "postgres";
    version     = "16.16";
    ip          = "192.168.20.224";
    uid         = 983;
    user        = "postgres";
    appPath     = "${config.homelab.rootPath}/postgres";
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
