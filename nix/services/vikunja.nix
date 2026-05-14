{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "${vars.services.rootPath}/vikunja";
in
{
  virtualisation.oci-containers.containers = {
    vikunja = {
      image = "vikunja/vikunja:${vars.services.vikunja.version}";
      user  = "${toString vars.services.vikunja.uid}:${toString vars.services.base_gid}";
      environment = {
        VIKUNJA_DATABASE_PATH  = "/db/vikunja.db";
        VIKUNJA_CORS_ENABLE    = "false";
        VIKUNJA_FILES_BASEPATH = "/files";
        TZ = "America/New_York";
      };
      volumes = [
        "${appPath}/db:/db"
        "${appPath}/files:/files"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.vikunja.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@todo=host todo.fatsch.us"
        "--label=caddy.handle=@todo"
        "--label=caddy.handle.reverse_proxy={{upstreams 3456}}"
        "--label=caddy.handle.import=cors"
      ];
    };
  };

  systemd.services.docker-vikunja = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
