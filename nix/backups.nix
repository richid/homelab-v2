{ config, lib, pkgs, ... }:
let
  zfs    = "${config.boot.zfs.package}/bin/zfs";
  mount  = "${pkgs.util-linux}/bin/mount";
  umount = "${pkgs.util-linux}/bin/umount";
  base   = "/run/restic-snap";
  snap   = "restic";

  skipDatasets = [ "influxdb" "watchstate" ];

  skipCases = lib.concatStringsSep "|" ([ "app-data" ] ++ map (d: "app-data/${d}") skipDatasets);

  destroySnapshot = flags: dataset: ''
    if ${zfs} list -H -t snapshot ${dataset}@${snap} >/dev/null 2>&1; then
      ${zfs} destroy ${flags} ${dataset}@${snap}
    fi
  '';

  cleanup = ''
    ${pkgs.gawk}/bin/awk -v b="${base}/" 'index($2, b) == 1 { print $2 }' /proc/mounts | ${pkgs.coreutils}/bin/sort -r | while read -r m; do
      ${umount} "$m"
    done
    ${destroySnapshot "-r" "app-data"}
    ${destroySnapshot "" "dozer/sync"}
  '';

  mountSnapshot = ''
    mount_snapshot() {
      ${pkgs.coreutils}/bin/mkdir -p "$2"
      ${mount} -t zfs -o ro "$1@${snap}" "$2"
    }
  '';
in
{
  age.secrets.restic-password.file   = ../secrets/restic-password.age;
  age.secrets.restic-repository.file = ../secrets/restic-repository.age;
  age.secrets.restic-s3.file         = ../secrets/restic-s3.env.age;

  services.restic.backups.s3 = {
    backupCleanupCommand = cleanup;
    backupPrepareCommand = ''
      set -e
      ${cleanup}
      ${mountSnapshot}
      ${zfs} snapshot -r app-data@${snap}
      ${zfs} snapshot dozer/sync@${snap}
      ${zfs} list -H -o name -d 1 app-data | while read -r ds; do
        case "$ds" in
          ${skipCases}) ;;
          *) mount_snapshot "$ds" "${base}/$ds" ;;
        esac
      done
      mount_snapshot dozer/sync "${base}/sync"
    '';
    checkOpts            = [ "--with-cache" ];
    environmentFile      = config.age.secrets.restic-s3.path;
    exclude              = [
      "${base}/app-data/**/*.log"
      "${base}/app-data/**/log"
      "${base}/app-data/**/logs"
      "${base}/app-data/jellyfin/config/cache"
      "${base}/app-data/jellyfin/config/data/transcodes"
      "${base}/app-data/smokeping/data"
      "${base}/app-data/tandoor/staticfiles"
      "${base}/app-data/tunarr/streams"
    ];
    extraOptions         = [ "s3.storage-class=INTELLIGENT_TIERING" ];
    initialize           = true;
    passwordFile         = config.age.secrets.restic-password.path;
    paths                = [ base ];
    pruneOpts            = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
    repositoryFile       = config.age.secrets.restic-repository.path;
    timerConfig          = {
      OnCalendar = "*-*-* 02:30:00";
      Persistent = true;
    };
  };

  systemd.services.restic-backups-s3 = {
    onFailure                = [ "notify-gotify@%n.service" ];
    serviceConfig.PrivateTmp = lib.mkForce false;
  };
}
