{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "${vars.services.rootPath}/influxdb";
in
{
  virtualisation.oci-containers.containers = {
    influxdb = {
      image = "influxdb:${vars.services.influxdb.version}";
      user  = "${toString vars.services.influxdb.uid}:${toString vars.services.base_gid}";
      environment = {
      };
      volumes = [
        "${appPath}/data:/var/lib/influxdb2"
        "${appPath}/config:/etc/influxdb2"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.influxdb.ip}"
        "--label=caddy=influx.schu"
        "--label=caddy.reverse_proxy={{upstreams 8086}}"
        "--label=caddy.tls=internal"
      ];
    };
  };

  systemd.services.docker-influxdb = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}