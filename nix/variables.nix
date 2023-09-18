{
  paths = {
    services = "/mnt/app-data";
  };

  services = {
    network = "services";

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
  };
}