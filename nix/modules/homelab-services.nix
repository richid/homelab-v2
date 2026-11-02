{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  cfg  = config.homelab.services;
  gids = config.homelab.gids;

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
        description = "User ID of the service. Null keeps the image user.";
      };
      group = mkOption {
        type        = types.enum (builtins.attrNames gids);
        default     = "services";
        description = "Group that the container runs as.";
      };
      uidMode = mkOption {
        type        = types.enum [ "user" "env" "none" ];
        default     = "user";
        description = "How the container gets uid and group: \"user\" sets --user, \"env\" sets the PUID and PGID environment variables (LinuxServer images), \"none\" sets neither.";
      };
      network = mkOption {
        type        = types.str;
        default     = config.homelab.network;
        description = "Docker network.";
      };
      caddyHost = mkOption {
        type        = types.nullOr types.str;
        default     = null;
        description = "Host name that Caddy serves for this container. Null adds no Caddy labels.";
      };
      caddyAliases = mkOption {
        type        = types.listOf types.str;
        default     = [ ];
        description = "More host names that Caddy serves with the same handler.";
      };
      caddyHeaderUp = mkOption {
        type        = types.nullOr types.str;
        default     = null;
        description = "Value of the reverse_proxy header_up directive. Null adds no header_up label.";
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
        type        = types.nullOr types.str;
        default     = "${config.homelab.rootPath}/${name}";
        description = "App data path. The container unit waits for this mount. Null adds no mount dependency.";
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
      preOptions = mkOption {
        type        = types.listOf types.str;
        default     = [ ];
        description = "Extra docker run options, added before the generated ones.";
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
      "--label=caddy.${matcher}=host ${lib.concatStringsSep " " ([ svc.caddyHost ] ++ svc.caddyAliases)}"
      "--label=caddy.handle=${matcher}"
      "--label=caddy.handle.reverse_proxy=${upstream}"
    ]
    ++ lib.optional (svc.caddyHeaderUp != null) "--label=caddy.handle.reverse_proxy.header_up=${svc.caddyHeaderUp}"
    ++ lib.optional svc.caddyCors "--label=caddy.handle.import=cors");

  container = _: svc: {
    image            = "${svc.image}:${svc.version}";
    user             = lib.mkIf (svc.uid != null && svc.uidMode == "user") "${toString svc.uid}:${toString gids.${svc.group}}";
    environment      = svc.environment // lib.optionalAttrs (svc.uid != null && svc.uidMode == "env") {
      PUID = toString svc.uid;
      PGID = toString gids.${svc.group};
    };
    environmentFiles = svc.environmentFiles;
    volumes          = svc.volumes;
    extraOptions     =
      svc.preOptions
      ++ [ "--network=${svc.network}" ]
      ++ lib.optional (svc.ip != null) "--ip=${svc.ip}"
      ++ caddyLabels svc
      ++ svc.extraOptions;
  };
in
{
  options.homelab = {
    rootPath = mkOption {
      type        = types.str;
      default     = "/mnt/app-data";
      description = "Parent folder of the service app data.";
    };
    network = mkOption {
      type        = types.str;
      default     = "services";
      description = "Default Docker network.";
    };
    gids = mkOption {
      type        = types.attrsOf types.int;
      default     = {
        services = 990;
        media    = 991;
        family   = 994;
      };
      description = "Group IDs by group name.";
    };
    services = mkOption {
      type        = types.attrsOf (types.submodule serviceOptions);
      default     = { };
      description = "Containers that the homelab runs.";
    };
  };

  config = {
    virtualisation.oci-containers.containers = lib.mapAttrs container cfg;

    systemd.services = lib.mapAttrs' (name: svc:
      lib.nameValuePair "docker-${name}" {
        unitConfig.RequiresMountsFor = svc.appPath;
      }) (lib.filterAttrs (_: svc: svc.appPath != null) cfg);
  };
}
