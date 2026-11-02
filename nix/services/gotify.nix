{ config, ... }:
let
  svc = config.homelab.services.gotify;
in
{
  homelab.services.gotify = {
    image         = "ghcr.io/gotify/server";
    version       = "3.1.1";
    ip            = "192.168.20.213";
    uid           = 987;
    caddyHost     = "gotify.fatsch.us";
    caddyHeaderUp = "-Origin";
    caddyCors     = true;
    environment   = {
      TZ = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/data:/app/data"
    ];
  };
}
