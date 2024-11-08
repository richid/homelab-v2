{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  secrets = import ../secrets.nix;
  appPath = "${vars.services.rootPath}/unifi";
in
{
  virtualisation.oci-containers.containers = {
    unifi = {
      image = "lscr.io/linuxserver/unifi-network-application:${vars.services.unifi.version}";
      environment = {
        PUID = toString vars.services.unifi.uid;
        PGID = toString vars.services.base_gid;

        MONGO_USER   = "unifi";
        MONGO_PASS   = secrets.unifi.mongo_password;
        MONGO_HOST   = "mongo44.fatschu.us";
        MONGO_PORT   = "27017";
        MONGO_DBNAME = "unifi";
        TZ           = "America/New_York";
      };
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
