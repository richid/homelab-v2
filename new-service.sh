#!/usr/bin/env bash
# new-service.sh - Scaffold a new homelab service
# Usage: ./new-service.sh <name> <image> <version> [quota=1G] [group=services]
#
# group: "services" (default) or "media"
#   services - standard user:group container, uses base_gid
#   media    - linuxserver.io PUID/PGID pattern, uses media_gid, mounts /mnt/tank

set -euo pipefail

NAME="${1:?Usage: $0 <name> <image> <version> [quota=1G] [group=services]}"
IMAGE="${2:?Usage: $0 <name> <image> <version> [quota=1G] [group=services]}"
VERSION="${3:?Usage: $0 <name> <image> <version> [quota=1G] [group=services]}"
QUOTA="${4:-1G}"
GROUP="${5:-services}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARS_FILE="$SCRIPT_DIR/nix/variables.nix"
SERVICE_FILE="$SCRIPT_DIR/nix/services/${NAME}.nix"

if [[ "$GROUP" != "services" && "$GROUP" != "media" ]]; then
  echo "Error: group must be 'services' or 'media'" >&2
  exit 1
fi

if [[ -f "$SERVICE_FILE" ]]; then
  echo "Error: $SERVICE_FILE already exists" >&2
  exit 1
fi

if grep -qE "^\s+${NAME}\s*=\s*\{" "$VARS_FILE"; then
  echo "Error: '${NAME}' already exists in variables.nix" >&2
  exit 1
fi

# Next UID: lowest existing uid minus 1
NEXT_UID=$(grep -oE 'uid\s*=\s*[0-9]+' "$VARS_FILE" | grep -oE '[0-9]+' | sort -n | head -1)
NEXT_UID=$((NEXT_UID - 1))

# Next IP: lowest free address in the service range
USED_IPS=$(grep -oE '192\.168\.20\.[0-9]+' "$VARS_FILE" | grep -oE '[0-9]+$' | sort -n)
NEXT_IP_LAST=""
for octet in $(seq 200 254); do
  if ! grep -qx "$octet" <<< "$USED_IPS"; then
    NEXT_IP_LAST=$octet
    break
  fi
done
if [[ -z "$NEXT_IP_LAST" ]]; then
  echo "Error: no free IPs in 192.168.20.200-254" >&2
  exit 1
fi
NEXT_IP="192.168.20.${NEXT_IP_LAST}"

# Insert new service block into variables.nix before the closing `  };` of services = { ... }
TMPFILE=$(mktemp "${TMPDIR:-/tmp}/new-service.XXXXXX")
ENTRY_FILE=$(mktemp "${TMPDIR:-/tmp}/new-service-entry.XXXXXX")

cat > "$ENTRY_FILE" << EOF

    ${NAME} = {
      ip      = "${NEXT_IP}";
      image   = "${IMAGE}";
      version = "${VERSION}";
      uid     = ${NEXT_UID};
    };
EOF

awk -v entryfile="$ENTRY_FILE" '
  /^  \};$/ && !inserted {
    while ((getline line < entryfile) > 0) print line
    inserted = 1
  }
  { print }
' "$VARS_FILE" > "$TMPFILE"
mv "$TMPFILE" "$VARS_FILE"
rm -f "$ENTRY_FILE"

# Generate service .nix file
if [[ "$GROUP" == "media" ]]; then
  cat > "$SERVICE_FILE" << EOF
{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "\${vars.services.rootPath}/${NAME}";
in
{
  virtualisation.oci-containers.containers = {
    ${NAME} = {
      image = "${IMAGE}:\${vars.services.${NAME}.version}";
      environment = {
        PUID = toString vars.services.${NAME}.uid;
        PGID = toString vars.services.media_gid;
        TZ   = "America/New_York";
      };
      volumes = [
        "\${appPath}/config:/config"
        "/mnt/tank:/tank"
      ];
      extraOptions = [
        "--network=services"
        "--ip=\${vars.services.${NAME}.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@${NAME}=host ${NAME}.fatsch.us"
        "--label=caddy.handle=@${NAME}"
        "--label=caddy.handle.reverse_proxy={{upstreams}}"
        "--label=caddy.handle.import=cors"
      ];
    };
  };

  systemd.services.docker-${NAME} = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
EOF
else
  cat > "$SERVICE_FILE" << EOF
{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  appPath = "\${vars.services.rootPath}/${NAME}";
in
{
  virtualisation.oci-containers.containers = {
    ${NAME} = {
      image = "${IMAGE}:\${vars.services.${NAME}.version}";
      user  = "\${toString vars.services.${NAME}.uid}:\${toString vars.services.base_gid}";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "\${appPath}/data:/data"
      ];
      extraOptions = [
        "--network=services"
        "--ip=\${vars.services.${NAME}.ip}"
        "--label=caddy=*.fatsch.us"
        "--label=caddy.@${NAME}=host ${NAME}.fatsch.us"
        "--label=caddy.handle=@${NAME}"
        "--label=caddy.handle.reverse_proxy={{upstreams}}"
        "--label=caddy.handle.import=cors"
      ];
    };
  };

  systemd.services.docker-${NAME} = {
    unitConfig = {
      RequiresMountsFor = appPath;
    };
  };
}
EOF
fi

# Determine user entry for configuration.nix
if [[ "$GROUP" == "media" ]]; then
  USER_ENTRY="        \"${NAME}\" = commonSvcCfg // { group = \"media\"; extraGroups = [ \"services\" ]; };"
else
  USER_ENTRY="        \"${NAME}\" = commonSvcCfg;"
fi

echo ""
echo "=========================================="
echo " Service '${NAME}' scaffolded"
echo "=========================================="
echo ""
echo "Files written:"
echo "  nix/variables.nix          (updated — IP: ${NEXT_IP}, UID: ${NEXT_UID})"
echo "  nix/services/${NAME}.nix   (created)"
echo ""
echo "--- 1. Add to configuration.nix users block ---"
echo ""
echo "  ${USER_ENTRY}"
echo ""
echo "--- 2. Run on gibson (after nixos-rebuild switch) ---"
echo ""
echo "  zfs create -o quota=${QUOTA} -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/${NAME} app-data/${NAME}"
echo "  chown -R ${NAME}:${GROUP} /mnt/app-data/${NAME}/"
echo ""
echo "--- 3. Add to README.md ---"
echo ""
printf "  | %-14s |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |\n" "${NAME}"
echo ""
echo "--- 4. Rebuild ---"
echo ""
echo "  nixos-rebuild switch"
echo ""
