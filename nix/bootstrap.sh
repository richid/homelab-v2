#!/bin/bash
# Script / commands used to bootstrap the NixOS server. These are mostly
# concerned with initial setup of ZFS arrays, formatting disks, etc. that is
# not handled by NixOS directly.

##### ZFS #####
# Create mirrored ZFS pool on NVMes for container application data
zpool create -o ashift=12 -m legacy app-data mirror \
  /dev/disk/by-id/nvme-WDC_WD_BLACK_SDBPNTY-256G-1106_210603800146 \
  /dev/disk/by-id/nvme-SPCC_M.2_PCIe_SSD_AA000000000000005666

# Create container datasets
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/gotify app-data/gotify
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/mosquitto app-data/mosquitto
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/scrutiny app-data/scrutiny
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/smokeping app-data/smokeping
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/uptime-kuma app-data/uptime-kuma
zfs create -o quota=5G -o compression=lz4 -o canmount=on -o mountpoint=/mnt/app-data/watchtower app-data/watchtower

##### MergerFS / Snapraid ####
mkfs.ext4 -m 0 -T largefile4 -L parity0 /dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA218QZ0
mkfs.ext4 -m 0 -T largefile4 -L parity1 /dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA21BXT1
mkfs.ext4 -m 1 -T largefile4 -L data0   /dev/disk/by-id/ata-ST10000NM0016-1TT101_ZA20WPHN

##### Docker #####
# Create macvlan network that uses bonded/LAG interface
docker network create -d macvlan --subnet=192.168.20.0/24 --gateway=192.168.20.1 -o parent=bond0 services