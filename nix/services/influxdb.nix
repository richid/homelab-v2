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
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@influx=host influx.fatsch.us"
        "--label=caddy.handle=@influx"
        "--label=caddy.handle.reverse_proxy={{upstreams 8086}}"
        "--label=caddy.handle.import=cors"
      ];
    };
  };

  systemd.services.docker-influxdb = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}