{
  paths = {
    services = "/mnt/app-data";
  };

  services = {
    network = "services";

    gotify = {
      ip      = "192.168.20.213";
      version = "2.4.0";
    };

    jellyfin = {
      ip      = "192.168.20.218";
      version = "10.8.10";
    };

    mosquitto = {
      ip      = "192.168.20.212";
      version = "2.0.17";
    };

    prowlarr = {
      ip      = "192.168.20.217";
      version = "1.9.1-nightly";
    };

    scrutiny = {
      ip      = "192.168.20.210";
      version = "v0.7.1-omnibus";
    };

    smokeping = {
      ip      = "192.168.20.211";
      version = "2.8.2";
    };

    transmission = {
      ip      = "192.168.20.216";
      version = "4.0.4";
    };

    uptime-kuma = {
      ip      = "192.168.20.215";
      version = "1";
    };

    watchstate = {
      ip      = "192.168.20.219";
      version = "master-20230915-063bdf4";
    };

    watchtower = {
      ip      = "192.168.20.214";
      version = "1.5.3";
    };
  };
}