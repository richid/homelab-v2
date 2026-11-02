{ config, ... }:
let
  svc = config.homelab.services.minecraft-java;
in
{
  homelab.services.minecraft-java = {
    image       = "itzg/minecraft-server";
    version     = "2026.10.1-java21";
    ip          = "192.168.20.230";
    uid         = 968;
    uidMode     = "none";
    appPath     = "${config.homelab.rootPath}/minecraft";
    environment = {
      EULA             = "true";
      TYPE             = "PAPER";
      UID              = toString svc.uid;
      GID              = toString config.homelab.gids.${svc.group};
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
