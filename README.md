# homelab-v2

Infrastructure, configuration, and documentation for v2 of the homelab.

## Deploy

`gibson` builds from the flake on GitHub. Push the branch first.

Changes go to `main` through a squash-merged pull request. The `check` workflow must build `gibson` first.

A merge to `main` deploys automatically: `nixos-upgrade.timer` checks every 5 minutes and switches when the commit changes. A failure sends an urgent alert (see [Alerts](#alerts)).

| Task | Command on `gibson` | Use |
|---|---|---|
| `task diff` | `nixos-rebuild build` + `nix store diff-closures` | See what changes |
| `task test` | `nixos-rebuild test` | Activate now. A reboot reverts it. |
| `task switch` | `nixos-rebuild switch` | Activate and make it the boot default |

Each task uses `--refresh --flake github:richid/homelab-v2/<ref>#gibson`. The default ref is `main`. To test a branch: `task test REF=<branch>`.

The timer switches back to `main` within 5 minutes. To keep a branch running, stop the timer first: `systemctl stop nixos-upgrade.timer`. Start it again when done.

## Alerts

- **Urgent**: goes to Gotify and to the Home Assistant webhook. The Home Assistant automation "Homelab Urgent Alert" sends the phone push and selects the devices. Payload: `{"source", "title", "message"}`.
- **Feed**: goes to Gotify only.

On `gibson`, `gibson-notify` in `nix/notify.nix` sends urgent alerts. Units use it through `onFailure = [ "notify-gotify@%n.service" ]`. ZED uses it as its mail program. Uptime Kuma ("Phone (urgent)", opt-in per monitor) and Scrutiny send to the webhook directly.

## Backups

`nix/backups.nix` backs up every `app-data` dataset and `/mnt/dozer/Sync` with restic, every night, to S3 (Intelligent-Tiering). The backup takes a `@restic` ZFS snapshot and mounts it read-only under `/run/restic-snap`, so database files are consistent. It does not use `.zfs/snapshot`, because the automount there can deadlock. Monitoring history (InfluxDB, Smokeping data), caches, generated files and logs are excluded. A failure sends an urgent alert.

The `restic-s3` command on `gibson` has the repository and the credentials set:

```
restic-s3 snapshots
restic-s3 restore latest --target /tmp/restore --include /run/restic-snap/app-data/<service>
```

## Hardware

## Services

Rootless: the service process runs as a non-root UID. LinuxServer and `itzg` images start as root, then drop to `PUID`/`UID`.

| Name           | Running | Stable | Monitoring | Rootless | Notes                                                   |
|----------------|:-------:|:------:|:----------:|:--------:|---------------------------------------------------------|
| Audiobookshelf |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| AWS DynDNS     |    ✅    |   ✅    |     🚫      |    🚫    | Updates `mc.fatsch.us` in Route 53                      |
| Caddy          |    ✅    |   ✅    |     ✅      |    🚫    | `caddy-docker-proxy`, needs Docker socket               |
| Gotify         |    ✅    |   ✅    |    N/A     |    ✅     |                                                         |
| Grafana        |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Homer          |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| InfluxDB       |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Jellyfin       |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Jellyseerr     |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Minecraft      |    ✅    |   ✅    |     🚫     |    ✅     |                                                         |
| Mongo          |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Mosquitto      |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Postgres       |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Prowlarr       |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Radarr         |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Scrutiny       |    ✅    |   ✅    |     ✅      |    🚫    | Can't run rootless, SMART requires root                 |
| Smokeping      |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Sonarr         |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Syncthing      |    ✅    |   ✅    |     🚫      |    ✅     |                                                         |
| Tandoor        |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Telegraf       |    ✅    |   ✅    |     ✅      |   N/A    | Runs on the host, not Docker                            |
| Trackage       |    ✅    |   ✅    |     🚫      |    ✅     |                                                         |
| Transmission   |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Tunarr         |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Unifi          |    ✅    |   ✅    |     ✅      |    ✅     |                                                         |
| Uptime Kuma    |    ✅    |   ✅    |     ✅      |    🚫    | Not easy to run rootless, needs access to Docker socket |
| Vikunja        |    ✅    |   ✅    |     🚫      |    ✅     |                                                         |
