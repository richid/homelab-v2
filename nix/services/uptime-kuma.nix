{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.uptime-kuma;
in
{
  homelab.services.uptime-kuma = {
    inherit (vars.services.uptime-kuma) image version ip;
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
