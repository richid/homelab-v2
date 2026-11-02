{ config, ... }:
let
  svc = config.homelab.services.uptime-kuma;
in
{
  homelab.services.uptime-kuma = {
    image       = "louislam/uptime-kuma";
    version     = "2.5.9";
    ip          = "192.168.20.215";
    caddyHost   = "status.fatsch.us";
    caddyCors   = true;
    environment = {
      PORT = "80";
    };
    volumes = [
      "${svc.appPath}/data:/app/data"
      "/var/run/docker.sock:/var/run/docker.sock"
    ];
    extraOptions = [
      "--pull=always"
    ];
  };
}
