{ config, pkgs, lib, ... }:
let
  vars     = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/minecraft";
in
{
  virtualisation.oci-containers.containers = {
    minecraft-java = {
      image = "itzg/minecraft-server:${vars.services.minecraft-java.version}";
      #user  = "${toString vars.services.minecraft-java.uid}:${toString vars.services.base_gid}";
      environment = {
        EULA    = "true";
        TYPE    = "PAPER";
        UID     = "${toString vars.services.minecraft-java.uid}";
        GID     = "${toString vars.services.base_gid}";
        MEMORY  = "4G";
        PLUGINS = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot\nhttps://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot";
      };
      volumes = [
        "${appPath}/java/data:/data"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.minecraft-java.ip}"
      ];
    };
  };

  systemd.services.docker-minecraft-java = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}