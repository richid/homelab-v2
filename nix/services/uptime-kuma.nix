{ config, pkgs, lib, ... }:
let
  vars     = import ../variables.nix;
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
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@status=host status.fatsch.us"
        "--label=caddy.handle=@status"
        "--label=caddy.handle.reverse_proxy={{upstreams}}"
        "--label=caddy.handle.import=cors"
        "--pull=newer"
      ];
    };
  };

  systemd.services.docker-uptime-kuma = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
