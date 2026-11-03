{ config, pkgs, ... }:
let
  notify = pkgs.writeShellScript "gibson-notify" ''
    set -a
    . ${config.age.secrets.gotify-gibson.path}
    . ${config.age.secrets.ha-webhook.path}
    set +a
    title=$1
    message=$(${pkgs.coreutils}/bin/cat)
    message=''${message:-No details.}
    rc=0
    ${pkgs.curl}/bin/curl -fsS -X POST -H "X-Gotify-Key: $GOTIFY_TOKEN" --form-string "title=$title" --form-string "message=$message" --form-string "priority=8" https://gotify.fatsch.us/message || rc=1
    ${pkgs.jq}/bin/jq -n --arg title "$title" --arg message "$message" '{source: "gibson", title: $title, message: $message}' | ${pkgs.curl}/bin/curl -fsS -X POST -H "Content-Type: application/json" --data-binary @- "$HA_WEBHOOK_URL" || rc=1
    exit $rc
  '';

  upsNotify = pkgs.writeShellScript "ups-notify" ''
    printf '%s' "$1" | ${notify} "gibson: UPS $NOTIFYTYPE"
  '';

  notifySecret = file: {
    inherit file;
    mode  = "0440";
    group = config.power.ups.upsmon.group;
  };
in
{
  age.secrets.gotify-gibson = notifySecret ../secrets/gotify-gibson.env.age;
  age.secrets.ha-webhook    = notifySecret ../secrets/ha-webhook.env.age;

  power.ups.upsmon.settings = {
    NOTIFYCMD  = "${upsNotify}";
    NOTIFYFLAG = map (event: [ event "SYSLOG+WALL+EXEC" ]) [ "ONBATT" "ONLINE" "LOWBATT" "FSD" "COMMBAD" "REPLBATT" ];
  };

  systemd.services."notify-gotify@" = {
    description = "Send a Gotify message and a Home Assistant push when %i fails";
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
