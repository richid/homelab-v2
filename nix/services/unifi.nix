{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "${vars.services.rootPath}/unifi";
in
{
  virtualisation.oci-containers.containers = {
    unifi = {
      image = "${vars.services.unifi.image}:${vars.services.unifi.version}";
      environment = {
        PUID = toString vars.services.unifi.uid;
        PGID = toString vars.services.base_gid;

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
        "${appPath}/config:/config"
      ];
      extraOptions = [
        "--network=mgmt"
        "--ip=${vars.services.unifi.ip}"
      ];
    };
  };

  systemd.services.docker-unifi = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
