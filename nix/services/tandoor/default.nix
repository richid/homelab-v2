{ config, pkgs, lib, ... }:
let
  vars    = import ../../variables.nix;
  appPath = "${vars.services.rootPath}/tandoor";
in
{
  virtualisation.oci-containers.containers = {
    tandoor = {
      image = "TandoorRecipes/recipes:${vars.services.tandoor.version}";
      user  = "${toString vars.services.tandoor.uid}:${toString vars.services.base_gid}";
      environment = {
        DB_ENGINE         = "django.db.backends.postgresql";
        POSTGRES_DB       = "tandoor";
        POSTGRES_HOST     = "${vars.services.postgres16.ip}";
        POSTGRES_PORT     = "5432";
        POSTGRES_USER     = "tandoor";
        POSTGRES_PASSWORD = "tandoor";
        SECRET_KEY        = "L0q3lqP42tIook9pDLuZrySKGBZLPaH4lU/CP2Rd/sMFPzV1dm";
      };
      volumes = [
        "${appPath}/staticfiles:/opt/recipes/staticfiles"
        "${appPath}/mediafiles:/opt/recipes/mediafiles"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.tandoor.ip}"
        "--label=caddy=recipes.schu tandoor.schu"
        "--label=caddy.reverse_proxy={{upstreams 8080}}"
        "--label=caddy.tls=internal"
        "--label=caddy.import=cors"
      ];
    };
  };

  systemd.services.docker-tandoor = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}