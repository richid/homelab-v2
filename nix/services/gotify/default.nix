{ config, pkgs, lib, ... }:
let
  vars    = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/gotify";
in
{
  virtualisation.oci-containers.containers = {
    gotify = {
      image = "ghcr.io/gotify/server:${vars.services.gotify.version}";
      user  = "${toString vars.services.gotify.uid}:${toString vars.services.base_gid}";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "${appPath}/data:/app/data"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.gotify.ip}"
        "--label=caddy=gotify.schu"
        "--label=caddy.reverse_proxy={{upstreams}}"
        "--label=caddy.tls=internal"
      ];
    };
  };

  systemd.services.docker-gotify = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}