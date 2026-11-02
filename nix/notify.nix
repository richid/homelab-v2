{ config, pkgs, ... }:
let
  notify = pkgs.writeShellScript "gibson-notify" ''
    set -a
    . ${config.age.secrets.gotify-gibson.path}
    set +a
    title=$1
    message=$(${pkgs.coreutils}/bin/cat)
    message=''${message:-No details.}
    exec ${pkgs.curl}/bin/curl -fsS -X POST -H "X-Gotify-Key: $GOTIFY_TOKEN" --form-string "title=$title" --form-string "message=$message" --form-string "priority=8" https://gotify.fatsch.us/message
  '';
in
{
  age.secrets.gotify-gibson.file = ../secrets/gotify-gibson.env.age;

  systemd.services."notify-gotify@" = {
    description = "Send a Gotify message when %i fails";
    serviceConfig.Type = "oneshot";
    scriptArgs = "%i";
    script = ''
      log=$(${config.systemd.package}/bin/journalctl -u "$1" -n 20 --no-pager -o cat)
      printf '%s' "''${log:-No log lines for $1.}" | ${notify} "gibson: $1 failed"
    '';
  };

  systemd.services.snapraid-sync.onFailure  = [ "notify-gotify@%n.service" ];
  systemd.services.snapraid-scrub.onFailure = [ "notify-gotify@%n.service" ];

  services.zfs.zed.settings = {
    ZED_EMAIL_ADDR = "root";
    ZED_EMAIL_PROG = "${notify}";
    ZED_EMAIL_OPTS = "'@SUBJECT@'";
  };
}
