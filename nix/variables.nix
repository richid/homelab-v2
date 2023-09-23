{
  services = {
    base_gid  = 990;
    media_gid = 991;
    network   = "services";
    rootPath  = "/mnt/app-data";

    gotify = {
      ip      = "192.168.20.213";
      version = "2.4.0";
      uid     = 987;
    };

    jellyfin = {
      ip      = "192.168.20.218";
      version = "10.8.10";
      uid     = 985;
    };

    mosquitto = {
      ip      = "192.168.20.212";
      version = "2.0.17";
      uid     = 988;
    };

    prowlarr = {
      ip      = "192.168.20.217";
      version = "1.9.1-nightly";
      uid     = 989;
    };

    radarr = {
      ip      = "192.168.20.220";
      version = "4.7.5";
      uid     = 982;
    };

    scrutiny = {
      ip      = "192.168.20.210";
      version = "v0.7.1-omnibus";
    };

    smokeping = {
      ip      = "192.168.20.211";
      version = "2.8.2";
      uid     = 993;
    };

    sonarr = {
      ip      = "192.168.20.221";
      version = "3.0.10";
      uid     = 981;
    };

    transmission = {
      ip      = "192.168.20.216";
      version = "4.0.4";
      uid     = 990;
    };

    uptime-kuma = {
      ip      = "192.168.20.215";
      version = "1";
    };

    watchstate = {
      ip      = "192.168.20.219";
      version = "master-20230915-063bdf4";
      uid     = 991;
    };

    watchtower = {
      ip      = "192.168.20.214";
      version = "1.5.3";
    };
  };
}