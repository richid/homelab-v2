{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  app_path = "${vars.paths.services}/uptime-kuma";
in
{
# docker run -d --restart=always -p 3001:3001 -v uptime-kuma:/app/data
  virtualisation.oci-containers.containers = {
    uptime-kuma = {
      image = "louislam/uptime-kuma:${vars.services.uptime-kuma.version}";
      environment = {
      };
      ports = [
        "3001:80"
      ];
      volumes = [
        "${app_path}/data:/app/data"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.uptime-kuma.ip}"
      ];
    };
  };

  systemd.services.docker-uptime-kuma = {
    unitConfig = {
      RequiresMountsFor = app_path;
    };
  };
}