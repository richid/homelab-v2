{ config, pkgs, lib, ... }:
let
  vars     = import ../variables.nix;
  appPath = "${vars.services.rootPath}/postgres";
in
{
  virtualisation.oci-containers.containers = {
    postgres16 = {
      image = "postgres:${vars.services.postgres16.version}";
      user  = "${toString vars.services.postgres16.uid}:${toString vars.services.base_gid}";
      environment = {
        POSTGRES_PASSWORD = "postgres";
        POSTGRES_USER     = "postgres";
        TZ                = "America/New_York";
      };
      volumes = [
        "${appPath}/v16/data:/var/lib/postgresql/data"
      ];
      extraOptions = [
        "--label=diun.include_tags=^16\..*"
        "--network=services"
        "--ip=${vars.services.postgres16.ip}"
      ];
    };
  };

  systemd.services.docker-postgres16 = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
