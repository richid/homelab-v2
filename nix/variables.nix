{
  paths = {
    services = "/mnt/app-data";
  };

  services = {
    network = "services";

    ips = {
      scrutiny  = "192.168.20.210";
      smokeping = "192.168.20.211";
    };
  };
}