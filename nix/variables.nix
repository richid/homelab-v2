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

    mosquitto = {
      ip      = "192.168.20.212";
      version = "2.0.17";
    };

    scrutiny = {
      ip      = "192.168.20.210";
      version = "v0.7.1-omnibus";
    };

    smokeping = {
      ip      = "192.168.20.211";
      version = "2.8.2";
    };

    uptime-kuma = {
      ip      = "192.168.20.215";
      version = "1";
    };

    watchtower = {
      ip      = "192.168.20.214";
      version = "1.5.3";
    };
  };
}