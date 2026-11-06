{ config, ... }:
let
  svc = config.homelab.services.homer;
in
{
  homelab.services.homer = {
    image       = "b4bz/homer";
    version     = "v26.08.3";
    ip          = "192.168.20.223";
    uid         = 986;
    caddyHost   = "home.fatsch.us";
    environment = {
      PORT = "80";
      TZ   = "America/New_York";
    };
    volumes = [
      "${svc.appPath}/config:/www/assets"
      "${./homer/config.yml}:/www/assets/config.yml:ro"
      "${./homer/cyberpunk.css}:/www/assets/cyberpunk.css:ro"
      "${./homer/icons}:/www/assets/icons:ro"
    ];
  };
}
