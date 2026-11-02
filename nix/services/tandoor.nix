{ config, ... }:
let
  svc = config.homelab.services.tandoor;
in
{
  homelab.services.tandoor = {
    image       = "vabene1111/recipes";
    version     = "2.7.2";
    ip          = "192.168.20.233";
    uid         = 966;
    caddyHost   = "recipes.fatsch.us";
    caddyPort   = 80;
    caddyCors   = true;
    environment = {
      ALLOWED_HOSTS        = "recipes.fatsch.us";
      CSRF_TRUSTED_ORIGINS = "https://recipes.fatsch.us";
      DB_ENGINE            = "django.db.backends.postgresql";
      POSTGRES_DB          = "tandoor";
      POSTGRES_HOST        = "postgres16";
      POSTGRES_PORT        = "5432";
      POSTGRES_USER        = "tandoor";
    };
    environmentFiles = [ config.age.secrets.tandoor.path ];
    volumes = [
      "${svc.appPath}/staticfiles:/opt/recipes/staticfiles"
      "${svc.appPath}/mediafiles:/opt/recipes/mediafiles"
    ];
  };
}
