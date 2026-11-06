{ config, ... }:
let
  appPath = "${config.homelab.rootPath}/immich";
  photos  = "/mnt/dozer/Photos";
  server  = config.homelab.services.immich-server;
  runAs   = "--user=${toString server.uid}:${toString config.homelab.gids.${server.group}}";
in
{
  homelab.services.immich-server = {
    image       = "ghcr.io/immich-app/immich-server";
    version     = "v3.3.6";
    ip          = "192.168.20.239";
    uid         = 959;
    user        = "immich";
    appPath     = appPath;
    caddyHost   = "photos.fatsch.us";
    caddyPort   = 2283;
    caddyCors   = true;
    environment = {
      DB_DATABASE_NAME            = "immich";
      DB_HOSTNAME                 = "immich-postgres";
      DB_USERNAME                 = "immich";
      IMMICH_MACHINE_LEARNING_URL = "http://immich-machine-learning:3003";
      REDIS_HOSTNAME              = "immich-valkey";
      TZ                          = "America/New_York";
    };
    environmentFiles = [ config.age.secrets.immich.path ];
    volumes = [
      "${photos}:/data"
      "${appPath}/thumbs:/data/thumbs"
      "${appPath}/encoded-video:/data/encoded-video"
    ];
    preOptions = [
      "--device=/dev/dri:/dev/dri"
    ];
  };

  homelab.services.immich-machine-learning = {
    image       = "ghcr.io/immich-app/immich-machine-learning";
    version     = "v3.3.6-openvino";
    ip          = "192.168.20.240";
    appPath     = appPath;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "${appPath}/model-cache:/cache"
    ];
    preOptions = [
      "--device=/dev/dri:/dev/dri"
    ];
    extraOptions = [
      runAs
    ];
  };

  homelab.services.immich-postgres = {
    image       = "ghcr.io/immich-app/postgres";
    version     = "17-vectorchord1.1.1";
    ip          = "192.168.20.241";
    appPath     = appPath;
    environment = {
      POSTGRES_DB          = "immich";
      POSTGRES_INITDB_ARGS = "--data-checksums";
      POSTGRES_USER        = "immich";
      TZ                   = "America/New_York";
    };
    environmentFiles = [ config.age.secrets.immich.path ];
    volumes = [
      "${appPath}/postgres:/var/lib/postgresql/data"
    ];
    extraOptions = [
      "--shm-size=128m"
      runAs
    ];
  };

  homelab.services.immich-valkey = {
    image       = "valkey/valkey";
    version     = "9.1.3";
    ip          = "192.168.20.242";
    appPath     = appPath;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "${appPath}/valkey:/data"
    ];
    extraOptions = [
      runAs
    ];
  };

  systemd.services.docker-immich-server = {
    after                        = [ "docker-immich-machine-learning.service" "docker-immich-postgres.service" "docker-immich-valkey.service" ];
    requires                     = [ "docker-immich-postgres.service" "docker-immich-valkey.service" ];
    unitConfig.RequiresMountsFor = [ photos ];
  };
}
