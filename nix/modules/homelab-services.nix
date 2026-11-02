{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  vars = import ../variables.nix;
  cfg  = config.homelab.services;

  gids = {
    services = vars.services.base_gid;
    media    = vars.services.media_gid;
    family   = vars.services.family_gid;
  };

  serviceOptions = { name, ... }: {
    options = {
      image = mkOption {
        type        = types.str;
        description = "Container image without the tag.";
      };
      version = mkOption {
        type        = types.str;
        description = "Container image tag.";
      };
      ip = mkOption {
        type        = types.nullOr types.str;
        default     = null;
        description = "Static IP on the Docker network.";
      };
      uid = mkOption {
        type        = types.nullOr types.int;
        default     = null;
        description = "User ID that the container runs as. Null keeps the image user.";
      };
      group = mkOption {
        type        = types.enum (builtins.attrNames gids);
        default     = "services";
        description = "Group that the container runs as.";
      };
      uidEnv = mkOption {
        type        = types.bool;
        default     = false;
        description = "Pass uid and group as the PUID and PGID environment variables instead of --user. LinuxServer images use this.";
      };
      network = mkOption {
        type        = types.str;
        default     = vars.services.network;
        description = "Docker network.";
      };
      caddyHost = mkOption {
        type        = types.nullOr types.str;
        default     = null;
        description = "Host name that Caddy serves for this container. Null adds no Caddy labels.";
      };
      caddyPort = mkOption {
        type        = types.nullOr types.port;
        default     = null;
        description = "Container port for Caddy. Null lets Caddy use the default.";
      };
      caddyCors = mkOption {
        type        = types.bool;
        default     = false;
        description = "Import the cors snippet in the Caddy handler.";
      };
      appPath = mkOption {
        type        = types.str;
        default     = "${vars.services.rootPath}/${name}";
        description = "App data path. The container unit waits for this mount.";
      };
      volumes = mkOption {
        type    = types.listOf types.str;
        default = [ ];
      };
      environment = mkOption {
        type    = types.attrsOf types.str;
        default = { };
      };
      environmentFiles = mkOption {
        type    = types.listOf types.path;
        default = [ ];
      };
      extraOptions = mkOption {
        type        = types.listOf types.str;
        default     = [ ];
        description = "Extra docker run options, added after the generated ones.";
      };
    };
  };

  caddyLabels = svc:
    let
      parts   = lib.splitString "." svc.caddyHost;
      matcher = "@${builtins.head parts}";
      domain  = "*.${lib.concatStringsSep "." (builtins.tail parts)}";
      upstream =
        if svc.caddyPort == null
        then "{{upstreams}}"
        else "{{upstreams ${toString svc.caddyPort}}}";
    in
    lib.optionals (svc.caddyHost != null) ([
      "--label=caddy=${domain}"
      "--label=caddy.${matcher}=host ${svc.caddyHost}"
      "--label=caddy.handle=${matcher}"
      "--label=caddy.handle.reverse_proxy=${upstream}"
    ] ++ lib.optional svc.caddyCors "--label=caddy.handle.import=cors");

  container = _: svc: {
    image            = "${svc.image}:${svc.version}";
    user             = lib.mkIf (svc.uid != null && !svc.uidEnv) "${toString svc.uid}:${toString gids.${svc.group}}";
    environment      = svc.environment // lib.optionalAttrs (svc.uid != null && svc.uidEnv) {
      PUID = toString svc.uid;
      PGID = toString gids.${svc.group};
    };
    environmentFiles = svc.environmentFiles;
    volumes          = svc.volumes;
    extraOptions     =
      [ "--network=${svc.network}" ]
      ++ lib.optional (svc.ip != null) "--ip=${svc.ip}"
      ++ caddyLabels svc
      ++ svc.extraOptions;
  };
in
{
  options.homelab.services = mkOption {
    type        = types.attrsOf (types.submodule serviceOptions);
    default     = { };
    description = "Containers that the homelab runs.";
  };

  config = {
    virtualisation.oci-containers.containers = lib.mapAttrs container cfg;

    systemd.services = lib.mapAttrs' (name: svc:
      lib.nameValuePair "docker-${name}" {
        unitConfig.RequiresMountsFor = svc.appPath;
      }) cfg;
  };
}
