{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/mongo";
in
{
  virtualisation.oci-containers.containers = {
    mongo44 = {
      image = "mongo:${vars.services.mongo44.version}";
      user  = "${toString vars.services.mongo44.uid}:${toString vars.services.base_gid}";
      volumes = [
        "${appPath}/v4.4/data:/data/db"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.mongo44.ip}"
        "--label=diun.include_tags=^4\\.\\d+\\.\\d+$"
        "--pull=newer"
      ];
    };
  };

  systemd.services.docker-mongo44 = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}