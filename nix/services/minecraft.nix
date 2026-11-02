{ config, ... }:
let
  vars = import ../variables.nix;
  svc  = config.homelab.services.minecraft-java;
in
{
  homelab.services.minecraft-java = {
    inherit (vars.services.minecraft-java) image version ip;
    appPath     = "${vars.services.rootPath}/minecraft";
    environment = {
      EULA             = "true";
      TYPE             = "PAPER";
      UID              = toString vars.services.minecraft-java.uid;
      GID              = toString vars.services.base_gid;
      MEMORY           = "4G";
      PLUGINS          = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot\nhttps://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot";
      SPIGET_RESOURCES = "28140";
      VERSION          = "1.21.11";
    };
    volumes = [
      "${svc.appPath}/java/data:/data"
    ];
  };
}
