{ config, lib, pkgs, ... }:
let
  svc    = config.homelab.services.homer;
  docker = "${config.virtualisation.docker.package}/bin/docker";
  sed    = "${pkgs.gnused}/bin/sed";
  grep   = "${pkgs.gnugrep}/bin/grep";
  script = ''<script src="assets/collapse.js" defer></script>'';
in
{
  homelab.services.homer = {
    image       = "b4bz/homer";
    version     = "v26.11.1";
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
      "${./homer/collapse.js}:/www/assets/collapse.js:ro"
      "${./homer/icons}:/www/assets/icons:ro"
      "/run/homer/index.html:/www/index.html:ro"
    ];
  };

  systemd.services.docker-homer.preStart = lib.mkAfter ''
    install -d -m 0755 /run/homer
    ${docker} run --rm --entrypoint cat ${svc.image}:${svc.version} /www/index.html > /run/homer/index.html.orig
    if ${grep} -q '</head>' /run/homer/index.html.orig; then
      ${sed} 's|</head>|${script}</head>|' /run/homer/index.html.orig > /run/homer/index.html
    else
      echo "homer: no </head> in the image index.html, serving it without collapse.js" >&2
      cp /run/homer/index.html.orig /run/homer/index.html
    fi
    chmod 0644 /run/homer/index.html
  '';
}
