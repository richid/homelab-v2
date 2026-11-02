#!/usr/bin/env bash
# new-service.sh - Scaffold a new homelab service
# Usage: ./new-service.sh <name> <image> <version> [quota=1G] [group=services]
#
# group: "services" (default) or "media"
#   services - standard user:group container
#   media    - linuxserver.io PUID/PGID pattern, uses the media group, mounts /mnt/tank

set -euo pipefail

NAME="${1:?Usage: $0 <name> <image> <version> [quota=1G] [group=services]}"
IMAGE="${2:?Usage: $0 <name> <image> <version> [quota=1G] [group=services]}"
VERSION="${3:?Usage: $0 <name> <image> <version> [quota=1G] [group=services]}"
QUOTA="${4:-1G}"
GROUP="${5:-services}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$SCRIPT_DIR/nix/services"
SERVICE_FILE="$SERVICES_DIR/${NAME}.nix"

if [[ "$GROUP" != "services" && "$GROUP" != "media" ]]; then
  echo "Error: group must be 'services' or 'media'" >&2
  exit 1
fi

if [[ -f "$SERVICE_FILE" ]]; then
  echo "Error: $SERVICE_FILE already exists" >&2
  exit 1
fi

if grep -qE "homelab\.services\.${NAME}\s*=" "$SERVICES_DIR"/*.nix; then
  echo "Error: homelab.services.${NAME} already exists" >&2
  exit 1
fi

# Next UID: lowest existing uid minus 1
NEXT_UID=$(cat "$SERVICES_DIR"/*.nix | grep -oE '^\s+uid\s*=\s*[0-9]+' | grep -oE '[0-9]+' | sort -n | head -1)
NEXT_UID=$((NEXT_UID - 1))

# Next IP: lowest free address in the service range
USED_IPS=$(cat "$SERVICES_DIR"/*.nix | grep -oE '^\s+ip\s*=\s*"192\.168\.20\.[0-9]+"' | grep -oE '[0-9]+"$' | tr -d '"' | sort -n)
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

# Generate service .nix file
if [[ "$GROUP" == "media" ]]; then
  cat > "$SERVICE_FILE" << EOF
{ config, ... }:
let
  svc = config.homelab.services.${NAME};
in
{
  homelab.services.${NAME} = {
    image       = "${IMAGE}";
    version     = "${VERSION}";
    ip          = "${NEXT_IP}";
    uid         = ${NEXT_UID};
    uidMode     = "env";
    group       = "media";
    caddyHost   = "${NAME}.fatsch.us";
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "\${svc.appPath}/config:/config"
      "/mnt/tank:/tank"
    ];
  };
}
EOF
else
  cat > "$SERVICE_FILE" << EOF
{ config, ... }:
let
  svc = config.homelab.services.${NAME};
in
{
  homelab.services.${NAME} = {
    image       = "${IMAGE}";
    version     = "${VERSION}";
    ip          = "${NEXT_IP}";
    uid         = ${NEXT_UID};
    caddyHost   = "${NAME}.fatsch.us";
    caddyCors   = true;
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "\${svc.appPath}/data:/data"
    ];
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
echo "  nix/services/${NAME}.nix   (created — IP: ${NEXT_IP}, UID: ${NEXT_UID})"
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
