# homelab-v2

Infrastructure, configuration, and documentation for v2 of the homelab.

## Hardware

## Services

| Name           | Running | Stable | Production | Monitoring | Rootless | Notes                                                   |
|----------------|:-------:|:------:|:----------:|:----------:|:--------:|---------------------------------------------------------|
| Audiobookshelf |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Caddy          |    ✅    |   ✅    |     ✅      |     ✅      |    🚫    | `caddy-docker-proxy`, needs Docker socket               |
| Diun           |    ✅    |   ✅    |     ✅      |     ✅      |    🚫    | Needs access to Docker socket                           |
| Emby           |   🚫    |   🚫   |     🚫     |     🚫     |    🚫    | Will not migrate -> Jellyfin                            |
| Gotify         |    ✅    |   ✅    |     ✅      |    N/A     |    ✅     |                                                         |
| Grafana        |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| HDBGo          |   🚫    |   🚫   |     🚫     |     🚫     |    🚫    | Will not migrate -> Prowlarr                            |
| Homer          |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| InfluxDB       |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Jellyfin       |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Jellyseerr     |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Minecraft      |    ✅    |   ✅    |     ✅      |     🚫     |    🚫    |                                                         |
| Mongo          |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Mosquitto      |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Netatalk       |   🚫    |   🚫   |     🚫     |     🚫     |    🚫    | Not using, moving to Samba                              |
| Plex           |   🚫    |   🚫   |     🚫     |     🚫     |    🚫    | Plex has been great, but time to say bye.               |
| Postgres       |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Prowlarr       |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Radarr         |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Scrutiny       |    ✅    |   ✅    |     ✅      |     ✅      |    🚫    | Can't run rootless, SMART requires root                 |
| Smokeping      |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Sonarr         |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Tandoor        |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Transmission   |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Unifi          |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Uptime Kuma    |    ✅    |   ✅    |     ✅      |     ✅      |    🚫    | Not easy to run rootless, needs access to Docker socket |
| Vector         |    ✅    |   ✅    |     ✅      |     ✅      |   N/A    | Runs on the host, not Docker                            |
| Watchstate     |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
