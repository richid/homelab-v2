{ config, pkgs, lib, ... }:
let
  vars    = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/grafana";
in
{
  virtualisation.oci-containers.containers = {
    grafana = {
      image = "grafana/grafana-oss:${vars.services.grafana.version}";
      user  = "${toString vars.services.grafana.uid}:${toString vars.services.base_gid}";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "${appPath}/data:/var/lib/grafana"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.grafana.ip}"
        "--label=caddy=grafana.schu"
        "--label=caddy.reverse_proxy={{upstreams 3000}}"
        "--label=caddy.tls=internal"
      ];
    };

    loki = { # Hmmmm, move to Influx???
      image = "grafana/loki:${vars.services.loki.version}";
      user  = "${toString vars.services.grafana.uid}:${toString vars.services.base_gid}";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "${appPath}/loki:/loki"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.loki.ip}"
      ];
    };
  };

  systemd.services.docker-grafana = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };

  systemd.services.docker-loki = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}