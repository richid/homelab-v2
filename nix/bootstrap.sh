#!/bin/bash
# Script / commands used to bootstrap the NixOS server. These are mostly
# concerned with initial setup of ZFS arrays, formatting disks, etc. that is
# not handled by NixOS directly.

# ZFS
## app-data - ZFS mirror on NVMes for container application data
zpool create -o ashift=12 -m legacy app-data mirror \
  /dev/disk/by-id/nvme-WDC_WD_BLACK_SDBPNTY-256G-1106_210603800146 \
  /dev/disk/by-id/nvme-SPCC_M.2_PCIe_SSD_AA000000000000005666

### Datasets
zfs create -o quota=1G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/audiobookshelf app-data/audiobookshelf
zfs create -o quota=1G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/caddy app-data/caddy
zfs create -o quota=1G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/diun app-data/diun
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/gotify app-data/gotify
zfs create -o quota=1G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/homer app-data/homer
zfs create -o quota=25G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/influxdb app-data/influxdb
zfs create -o quota=10G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/grafana app-data/grafana
zfs create -o quota=50G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/jellyfin app-data/jellyfin
zfs create -o quota=1G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/jellyseerr app-data/jellyseerr
zfs create -o quota=10G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/minecraft app-data/minecraft
zfs create -o quota=10G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/mongo app-data/mongo
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/mosquitto app-data/mosquitto
zfs create -o quota=10G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/postgres app-data/postgres
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/prowlarr app-data/prowlarr
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/radarr app-data/radarr
zfs create -o quota=1G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/scrutiny app-data/scrutiny
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/smokeping app-data/smokeping
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/sonarr app-data/sonarr
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/tandoor app-data/tandoor
zfs create -o quota=1G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/transmission app-data/transmission
zfs create -o quota=1G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/tunarr app-data/tunarr
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/unifi app-data/unifi
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/uptime-kuma app-data/uptime-kuma
zfs create -o quota=1G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/watchstate app-data/watchstate

## dozer - ZFS mirrors on HDDs for high-value data
zpool create -o ashift=12 -m legacy dozer mirror \
  /dev/disk/by-id/ata-ST3500630AS_9QG1ATEN \
  /dev/disk/by-id/ata-ST3500630AS_9QG1ATWD \

zpool add -o ashift=12 dozer mirror \
  /dev/disk/by-id/ata-ST3500630AS_9QG1BZDG \
  /dev/disk/by-id/ata-ST3500630AS_9QG1C94E

###  Datasets
zfs create -o compression=lz4 -o canmount=on -o mountpoint=/mnt/dozer/Backups dozer/backups
zfs create -o compression=lz4 -o canmount=on -o mountpoint=/mnt/dozer/Dropbox dozer/dropbox


##### MergerFS / Snapraid #####
mkfs.ext4 -m 0 -T largefile4 -L parity0 /dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA218QZ0
mkfs.ext4 -m 0 -T largefile4 -L parity1 /dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA21BXT1
mkfs.ext4 -m 1 -T largefile4 -L data0   /dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA20WPHN # DEAD
mkfs.ext4 -m 1 -T largefile4 -L data1   /dev/disk/by-id/ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K1CZK8JC
mkfs.ext4 -m 1 -T largefile4 -L data2   /dev/disk/by-id/ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K2JYLLHL
mkfs.ext4 -m 1 -T largefile4 -L data3   /dev/disk/by-id/ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K2LD2NTR
mkfs.ext4 -m 1 -T largefile4 -L data4   /dev/disk/by-id/ata-WDC_WD40PURX-64NZ6Y0_WD-WCC7K4FEACY1
mkfs.ext4 -m 1 -T largefile4 -L data5   /dev/disk/by-id/ata-WDC_WD40EURX-64WRWY0_WD-WCC4E1745891
mkfs.ext4 -m 1 -T largefile4 -L data6   /dev/disk/by-id/ata-WDC_WD40EURX-64WRWY0_WD-WCC4E2036120
mkfs.ext4 -m 1 -T largefile4 -L data7   /dev/disk/by-id/ata-WDC_WD40EURX-64WRWY0_WD-WCC4E2056001
mkfs.ext4 -m 1 -T largefile4 -L data8   /dev/disk/by-id/ata-HUH721010ALE601_7PK1UM0G

##### Docker #####
# Create macvlan network that uses bonded/LAG interface
docker network create -d macvlan --subnet=192.168.20.0/24 --gateway=192.168.20.1 -o parent=bond0 services
docker network create -d macvlan --subnet=192.168.10.0/24 --gateway=192.168.10.1 -o parent=eno1 mgmt

##### Permissions #####
chown -R rich:media /mnt/tank/media/
chmod -R 775 /mnt/tank/media/

chown -R audiobookshelf:services /mnt/app-data/audiobookshelf/
chown -R caddy:services /mnt/app-data/caddy/
chown -R diun:services /mnt/app-data/diun/
chown -R gotify:services /mnt/app-data/gotify/
chown -R grafana:services /mnt/app-data/grafana/
chown -R homer:services /mnt/app-data/homer/
chown -R influxdb:services /mnt/app-data/influxdb/
chown -R jellyfin:media /mnt/app-data/jellyfin/
chown -R minecraft:services /mnt/app-data/minecraft/
chown -R mongo:services /mnt/app-data/mongo/
chown -R mosquitto:services /mnt/app-data/mosquitto/
chown -R jellyseerr:services /mnt/app-data/jellyseerr/
chown -R postgres:services /mnt/app-data/postgres/
chown -R prowlarr:services /mnt/app-data/prowlarr/
chown -R radarr:media /mnt/app-data/radarr/
chown -R smokeping:services /mnt/app-data/smokeping/
chown -R sonarr:media /mnt/app-data/sonarr/
chown -R tandoor:services /mnt/app-data/tandoor/
chown -R transmission:media /mnt/app-data/transmission/
chown -R tunarr:media /mnt/app-data/tunarr/
chown -R unifi:services /mnt/app-data/unifi/
chown -R watchstate:services /mnt/app-data/watchstate/

##### Postgres Migration #####
1. Spin up PG16 Docker container
2. Create hass:hass user in new cluster
  a. `CREATE USER hass WITH PASSWORD 'hass';`
  b. `CREATE DATABASE home_assistant WITH OWNER hass ENCODING 'utf8';`
3. Stop HASS from writing to the DB (unplug the network cable :D)
4. Dump existing data
  a. `pg_dump -U postgres home_assistant | gzip > home_assistant.gz`
5. Import data into new schema
  a. `gunzip -c home_assistant.gz | psql --set ON_ERROR_STOP=on -U postgres home_assistant


##### MongoDB Migration #####
1. Spin up MongoDB 4.4 Docker container
2. Stop Unifi controller
3. Dump existing data: mongodump
4. Import data: mongorestore
5. Start Unifi controller

#### Unifi Migration #####
use unifi
db.createUser({ user: "unifi", pwd: passwordPrompt(), roles: [{ role: "dbAdmin", db: "unifi" },{ role: "dbAdmin", db: "unifi_stat" }]});

use unifi_stat
db.createUser({ user: "unifi", pwd: passwordPrompt(), roles: [{ role: "dbAdmin", db: "unifi" },{ role: "dbAdmin", db: "unifi_stat" }]});

## Backups

[nix-shell:~]# restic -r rclone:gdrive:/BCackups init
enter password for new repository:
enter password again:
created restic repository e60c554e7e at rclone:gdrive:/BCackups

Please note that knowledge of your password is required to access
the repository. Losing your password means that your data is
irrecoverably lost.

Using restic + reclone to save to Google Drive
Configuration rclone using a custom OAuth App following https://rclone.org/drive/#making-your-own-client-id

#### Tandoor Setup
CREATE USER tandoor WITH PASSWORD 'tandoor';
GRANT ALL PRIVILEGES ON DATABASE tandoor TO tandoor;
ALTER DATABASE tandoor OWNER TO tandoor;
ALTER ROLE tandoor SET client_encoding TO 'utf8';
ALTER ROLE tandoor SET default_transaction_isolation TO 'read committed';
ALTER ROLE tandoor SET timezone TO 'UTC';
ALTER USER tandoor WITH SUPERUSER;
