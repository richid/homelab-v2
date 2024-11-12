#!/run/current-system/sw/bin/bash

/run/current-system/sw/bin/zpool list -Hp -o name,capacity | while read -r pool capacity; do
    echo "zfs_pool,pool=$pool used_percent=${capacity}i"
done