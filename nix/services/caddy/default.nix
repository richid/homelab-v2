{ config, pkgs, lib, ... }:
let
  vars    = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/caddy";
in
{
  virtualisation.oci-containers.containers = {
    caddy = {
      image = "caddy:${vars.services.caddy.version}";
      user  = "${toString vars.services.caddy.uid}:${toString vars.services.base_gid}";
      environment = {
        TZ = "America/New_York";
      };
      ports = [
        "443:443"
      ];
      volumes = [
        "${appPath}/data:/data"
        "${appPath}/config:/config"
        "${appPath}/config/Caddyfile:/etc/caddy/Caddyfile"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.caddy.ip}"
      ];
    };
  };

  systemd.services.docker-caddy = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };

    serviceConfig = {
      ExecReload = "${pkgs.docker}/bin/docker exec -w /etc/caddy caddy caddy reload";
    };
  };

  systemd.services.docker-caddy-watcher = {
    unitConfig = {
      Description = "Reload Caddy configuration when Caddyfile changed.";
      After       = "network.target";

      StartLimitIntervalSec = "10";
      StartLimitBurst       = "5";
    };

    serviceConfig = {
      Type      = "oneshot";
      ExecStart = "systemctl reload docker-caddy.service";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.paths.docker-caddy-watcher = {
    pathConfig = {
      Unit        = "docker-caddy-watcher.service";
      PathChanged = "${appPath}/config/Caddyfile";
    };

    wantedBy = ["multi-user.target"];
  };
}