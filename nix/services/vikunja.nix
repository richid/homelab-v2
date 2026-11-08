{ config, ... }:
let
  svc = config.homelab.services.vikunja;
in
{
  homelab.services.vikunja = {
    image       = "vikunja/vikunja";
    version     = "2.8.0";
    ip          = "192.168.20.238";
    uid         = 960;
    caddyHost   = "todo.fatsch.us";
    caddyPort   = 3456;
    caddyCors   = true;
    environment = {
      VIKUNJA_DATABASE_PATH  = "/db/vikunja.db";
      VIKUNJA_CORS_ENABLE    = "false";
      VIKUNJA_FILES_BASEPATH = "/files";
      TZ                     = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/db:/db"
      "${svc.appPath}/files:/files"
    ];
  };
}
