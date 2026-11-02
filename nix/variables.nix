{
  services = {
    base_gid   = 990;
    family_gid = 994;
    media_gid  = 991;
    network    = "services";
    rootPath   = "/mnt/app-data";

    audiobookshelf = {
      ip      = "192.168.20.234";
      image   = "ghcr.io/advplyr/audiobookshelf";
      version = "2.37.2";
      uid     = 965;
    };

    aws-dyndns = {
      image   = "sjmayotte/route53-dynamic-dns";
      version = "v1.4.5";
    };

    caddy = {
      ip      = "192.168.20.200";
      image   = "ghcr.io/richid/caddy-docker-proxy-r53-dns";
      version = "2.8.4";
      uid     = 977;
    };

    gotify = {
      ip      = "192.168.20.213";
      image   = "ghcr.io/gotify/server";
      version = "3.1.1";
      uid     = 987;
    };

    grafana = {
      ip      = "192.168.20.226";
      image   = "grafana/grafana";
      version = "13.3.0";
      uid     = 971;
    };

    homer = {
      ip      = "192.168.20.223";
      image   = "b4bz/homer";
      version = "v26.08.3";
      uid     = 986;
    };

    influxdb = {
      ip      = "192.168.20.228";
      image   = "influxdb";
      version = "2.9.1";
      uid     = 970;
    };

    jellyfin = {
      ip      = "192.168.20.218";
      image   = "lscr.io/linuxserver/jellyfin";
      version = "10.11.11";
      uid     = 985;
    };

    jellyseerr = {
      ip      = "192.168.20.222";
      image   = "fallenbagel/jellyseerr";
      version = "2.7.3";
      uid     = 978;
    };

    minecraft-java = {
      ip      = "192.168.20.230";
      image   = "itzg/minecraft-server";
      version = "2026.10.1-java21";
      uid     = 968;
    };

    mongo = {
      ip      = "192.168.20.225";
      image   = "mongo";
      version = "4.4.30";
      uid     = 984;
    };

    mosquitto = {
      ip      = "192.168.20.212";
      image   = "eclipse-mosquitto";
      version = "2.0.22";
      uid     = 988;
    };

    postgres16 = {
      ip      = "192.168.20.224";
      image   = "postgres";
      version = "16.15";
      uid     = 983;
    };

    prowlarr = {
      ip      = "192.168.20.217";
      image   = "lscr.io/linuxserver/prowlarr";
      version = "2.7.0";
      uid     = 989;
    };

    radarr = {
      ip      = "192.168.20.220";
      image   = "lscr.io/linuxserver/radarr";
      version = "6.4.4";
      uid     = 982;
    };

    scrutiny = {
      ip      = "192.168.20.210";
      image   = "ghcr.io/analogj/scrutiny";
      version = "v0.7.1-omnibus";
    };

    smokeping = {
      ip      = "192.168.20.211";
      image   = "lscr.io/linuxserver/smokeping";
      version = "2.9.0";
      uid     = 993;
    };

    sonarr = {
      ip      = "192.168.20.221";
      image   = "lscr.io/linuxserver/sonarr";
      version = "4.0.20";
      uid     = 981;
    };

    syncthing = {
      ip      = "192.168.20.236";
      image   = "lscr.io/linuxserver/syncthing";
      version = "2.1.7";
      uid     = 1000; # rich
    };

    tandoor = {
      ip      = "192.168.20.233";
      image   = "vabene1111/recipes";
      version = "2.7.2";
      uid     = 966;
    };

    trackage = {
      ip      = "192.168.20.237";
      image   = "ghcr.io/richid/trackage";
      version = "0.4.0";
      uid     = 961;
    };

    transmission = {
      ip      = "192.168.20.216";
      image   = "lscr.io/linuxserver/transmission";
      version = "4.1.4";
      uid     = 990;
    };

    tunarr = {
      ip      = "192.168.20.235";
      image   = "ghcr.io/chrisbenincasa/tunarr";
      version = "1.3.15";
      uid     = 964;
    };

    unifi = {
      ip      = "192.168.10.10";
      image   = "lscr.io/linuxserver/unifi-network-application";
      version = "10.6.109";
      uid     = 975;
    };

    uptime-kuma = {
      ip      = "192.168.20.215";
      image   = "louislam/uptime-kuma";
      version = "2.5.9";
    };

    vikunja = {
      ip      = "192.168.20.238";
      image   = "vikunja/vikunja";
      version = "2.7.1";
      uid     = 960;
    };
  };
}
