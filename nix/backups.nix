{ config, lib, ... }:
let
  zfs  = "${config.boot.zfs.package}/bin/zfs";
  root = config.homelab.rootPath;
  snap = "restic";

  skipDatasets = [ "influxdb" "watchstate" ];

  snapPath = dataset: "${root}/${dataset}/.zfs/snapshot/${snap}";

  skipCases = lib.concatStringsSep "|" ([ "app-data" ] ++ map (d: "app-data/${d}") skipDatasets);

  destroySnapshot = flags: dataset: ''
    if ${zfs} list -H -t snapshot ${dataset}@${snap} >/dev/null 2>&1; then
      ${zfs} destroy ${flags} ${dataset}@${snap}
    fi
  '';

  destroySnapshots = ''
    ${destroySnapshot "-r" "app-data"}
    ${destroySnapshot "" "dozer/sync"}
  '';
in
{
  age.secrets.restic-password.file   = ../secrets/restic-password.age;
  age.secrets.restic-repository.file = ../secrets/restic-repository.age;
  age.secrets.restic-s3.file         = ../secrets/restic-s3.env.age;

  services.restic.backups.s3 = {
    backupCleanupCommand = destroySnapshots;
    backupPrepareCommand = ''
      ${destroySnapshots}
      ${zfs} snapshot -r app-data@${snap}
      ${zfs} snapshot dozer/sync@${snap}
    '';
    checkOpts            = [ "--with-cache" ];
    dynamicFilesFrom     = ''
      ${zfs} list -H -o name -d 1 app-data | while read -r ds; do
        case "$ds" in
          ${skipCases}) ;;
          *) echo "${root}/''${ds#app-data/}/.zfs/snapshot/${snap}" ;;
        esac
      done
      echo "/mnt/dozer/Sync/.zfs/snapshot/${snap}"
    '';
    environmentFile      = config.age.secrets.restic-s3.path;
    exclude              = [
      "${root}/*/.zfs/snapshot/${snap}/**/*.log"
      "${root}/*/.zfs/snapshot/${snap}/**/log"
      "${root}/*/.zfs/snapshot/${snap}/**/logs"
      "${snapPath "jellyfin"}/config/cache"
      "${snapPath "jellyfin"}/config/data/transcodes"
      "${snapPath "smokeping"}/data"
      "${snapPath "tandoor"}/staticfiles"
      "${snapPath "tunarr"}/streams"
    ];
    extraOptions         = [ "s3.storage-class=INTELLIGENT_TIERING" ];
    initialize           = true;
    passwordFile         = config.age.secrets.restic-password.path;
    pruneOpts            = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
    repositoryFile       = config.age.secrets.restic-repository.path;
    timerConfig          = {
      OnCalendar = "*-*-* 02:30:00";
      Persistent = true;
    };
  };

  systemd.services.restic-backups-s3.onFailure = [ "notify-gotify@%n.service" ];
}
