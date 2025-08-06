{
  services = {
    base_gid  = 990;
    media_gid = 991;
    network   = "services";
    rootPath  = "/mnt/app-data";

    audiobookshelf = {
      ip      = "192.168.20.234";
      version = "2.27.0";
      uid     = 965;
    };

    caddy = {
      ip      = "192.168.20.200";
      version = "2.8.4";
      uid     = 977;
    };

    diun = {
      ip      = "192.168.20.214";
      version = "4.29.0";
      uid     = 976;
    };

    gotify = {
      ip      = "192.168.20.213";
      version = "2.6.3";
      uid     = 987;
    };

    grafana = {
      ip      = "192.168.20.226";
      version = "12.1.0";
      uid     = 971;
    };

    homer = {
      ip      = "192.168.20.223";
      version = "v24.12.1";
      uid     = 986;
    };

    influxdb = {
      ip      = "192.168.20.228";
      version = "2.7.12";
      uid     = 970;
    };

    jellyfin = {
      ip      = "192.168.20.218";
      version = "10.10.1";
      uid     = 985;
    };

    jellyseerr = {
      ip      = "192.168.20.222";
      version = "2.7.2";
      uid     = 978;
    };

    minecraft-java = {
      ip      = "192.168.20.230";
      version = "stable";
      uid     = 968;
    };

    mongo44 = {
      ip      = "192.168.20.225";
      version = "4.4";
      uid     = 984;
    };

    mosquitto = {
      ip      = "192.168.20.212";
      version = "2.0.22";
      uid     = 988;
    };

    postgres16 = {
      ip      = "192.168.20.224";
      version = "16.9";
      uid     = 983;
    };

    prowlarr = {
      ip      = "192.168.20.217";
      version = "1.37.0";
      uid     = 989;
    };

    radarr = {
      ip      = "192.168.20.220";
      version = "5.26.2";
      uid     = 982;
    };

    scrutiny = {
      ip      = "192.168.20.210";
      version = "v0.7.1-omnibus";
    };

    smokeping = {
      ip      = "192.168.20.211";
      version = "2.9.0";
      uid     = 993;
    };

    sonarr = {
      ip      = "192.168.20.221";
      version = "4.0.15";
      uid     = 981;
    };

    tandoor = {
      ip      = "192.168.20.233";
      version = "1.5.35";
      uid     = 966;
    };

    transmission = {
      ip      = "192.168.20.216";
      version = "4.0.4";
      uid     = 990;
    };

    tunarr = {
      ip      = "192.168.20.235";
      version = "0.20.6";
      uid     = 964;
    };

    unifi = {
      ip      = "192.168.10.10";
      version = "9.3.45";
      uid     = 975;
    };

    uptime-kuma = {
      ip      = "192.168.20.215";
      version = "1";
    };

    watchstate = {
      ip      = "192.168.20.219";
      version = "master-20241116-c66994a";
      uid     = 991;
    };
  };
}
