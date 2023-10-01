{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/uptime-kuma";
in
{
  virtualisation.oci-containers.containers = {
    uptime-kuma = {
      image = "louislam/uptime-kuma:${vars.services.uptime-kuma.version}";
      environment = {
        PORT = "80";
      };
      volumes = [
        "${appPath}/data:/app/data"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.uptime-kuma.ip}"
        "--label=caddy=status.schu"
        "--label=caddy.reverse_proxy={{upstreams}}"
        "--label=caddy.tls=internal"
      ];
    };
  };

  systemd.services.docker-uptime-kuma = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
