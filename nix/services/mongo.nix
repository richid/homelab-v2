{ config, pkgs, lib, ... }:
let
  vars     = import ../variables.nix;
  appPath = "${vars.services.rootPath}/mongo";
in
{
  virtualisation.oci-containers.containers = {
    mongo = {
      image = "${vars.services.mongo.image}:${vars.services.mongo.version}";
      user  = "${toString vars.services.mongo.uid}:${toString vars.services.base_gid}";
      volumes = [
        "${appPath}/v4.4/data:/data/db"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.mongo.ip}"
        "--pull=always"
      ];
    };
  };

  systemd.services.docker-mongo = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}