# homelab-v2

Infrastructure, configuration, and documentation for v2 of the homelab.

## Hardware


## Services

| Name         | Running | Stable | Production | Monitoring | Rootless | Notes                                                   |
|--------------|:-------:|:------:|:----------:|:----------:|:--------:|---------------------------------------------------------|
| Emby         |   🚫    |   🚫   |     🚫     |     🚫     |    🚫    | Will not migrate -> Jellyfin                            |
| Gotify       |    ✅    |   ✅    |     ✅      |    N/A     |          |                                                         |
| HDBGo        |   🚫    |   🚫   |     🚫     |     🚫     |    🚫    | Will not migrate -> Prowlarr                            |
| Homer        |         |        |            |            |          |                                                         |
| Jellyfin     |    ✅    |   ✅    |            |     ✅      |    ✅     |                                                         |
| Minecraft    |   🚫    |   🚫   |     🚫     |     🚫     |    🚫    |                                                         |
| Mongo        |         |        |            |            |          |                                                         |
| Mosquitto    |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     | Need to point mqtt.schu to new IP                       |
| Netatalk     |         |        |            |            |          |                                                         |
| Plex         |   🚫    |   🚫   |     🚫     |     🚫     |    🚫    | Plex has been great, but time to say bye.               |
| Postgres     |         |        |            |            |          |                                                         |
| Prowlarr     |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Radarr       |         |        |            |            |          |                                                         |
| Scrutiny     |    ✅    |   ✅    |     ✅      |     ✅      |    🚫    | Can't run rootless, SMART requires root                 | 
| Smokeping    |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Sonarr       |         |        |            |            |          |                                                         |
| Transmission |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Uptime Kuma  |    ✅    |   ✅    |     ✅      |     ✅      |    🚫    | Not easy to run rootless, needs access to Docker socket |
| Watchstate   |    ✅    |   ✅    |     ✅      |     ✅      |    ✅     |                                                         |
| Watchtower   |    ✅    |   ✅    |     ✅      |     ✅      |    🚫    | Not easy to run rootless, needs access to Docker socket |
