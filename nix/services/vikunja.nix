{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.vikunja;
in
{
  homelab.services.vikunja = {
    inherit (vars.services.vikunja) image version ip uid;
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
