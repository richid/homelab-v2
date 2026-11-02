{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "${vars.services.rootPath}/tandoor";
in
{
  virtualisation.oci-containers.containers = {
    tandoor = {
      image = "${vars.services.tandoor.image}:${vars.services.tandoor.version}";
      user  = "${toString vars.services.tandoor.uid}:${toString vars.services.base_gid}";
      environment = {
        DB_ENGINE         = "django.db.backends.postgresql";
        GUNICORN_MEDIA    = "1";
        POSTGRES_DB       = "tandoor";
        POSTGRES_HOST     = "${vars.services.postgres16.ip}";
        POSTGRES_PORT     = "5432";
        POSTGRES_USER     = "tandoor";
      };
      environmentFiles = [ config.age.secrets.tandoor.path ];
      volumes = [
        "${appPath}/staticfiles:/opt/recipes/staticfiles"
        "${appPath}/mediafiles:/opt/recipes/mediafiles"
      ];
      extraOptions = [
        "--network=services"
        "--ip=${vars.services.tandoor.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@recipes=host recipes.fatsch.us"
        "--label=caddy.handle=@recipes"
        "--label=caddy.handle.reverse_proxy={{upstreams 80}}"
        "--label=caddy.handle.import=cors"
      ];
    };
  };

  systemd.services.docker-tandoor = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
