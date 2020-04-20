
# [RandomNinjaAtk/sonarr-sma](https://github.com/RandomNinjaAtk/docker-sonarr-sma)

[Sonarr](https://sonarr.tv/) is a PVR for usenet and bittorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.


[![sonarr](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/sonarr-banner.png)](https://sonarr.tv/)

This containers base image is provided by: [linuxserver/sonarr:preview](https://github.com/linuxserver/docker-sonarr)


## Supported Architectures

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |

## Version Tags

| Tag | Description |
| :----: | --- |
| latest | Sonarr V3 + SMA + ffmpeg |

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8989` | The port for the Sonarr webinterface |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London, this is required for Sonarr |
| `-e UMASK_SET=022` | control permissions of files and directories created by Sonarr |
| `-v /config` | Database and sonarr configs |
| `-v /storage` | Location of TV and Downloads Library |
| `-e UPDATE_SMA=FALSE` | TRUE = enabled :: Update SMA on container startup |

## Application Setup

Access the webui at `<your-ip>:8989`, for more information check out [Sonarr](https://sonarr.tv/).

# Sonarr Configuration

### Enable completed download handling
* Settings -> Download Client -> Completed Download Handling -> Enable: Yes

### Add Custom Script
* Settings -> Connect -> + Add -> custom Script

| Parameter | Value |
| --- | --- |
| On Grab | No |
| On Import | Yes |
| On Upgrade | Yes |
| On Rename | No |
| On Health Issue | No |
| Tags | leave blank |
| Path | `/scripts/postSonarr.sh` |

# SMA Information:

### Config Information
Located at `/config/sma/autoProcess.ini` inside the container

### Log Information
Located at `/config/sma/sma.log` inside the container

### Hardware Acceleration

1. Set "video codec" to: `h264vaapi` or `h265vaapi` in "/config/sma/autoProcess.ini"
1. Make sure you have passed the correct device to the container, or these will not work...
