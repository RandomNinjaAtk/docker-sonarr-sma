ARG ffmpeg_tag=snapshot-vaapi
FROM mdhiggins/sonarr-sma:build
LABEL maintainer="RandomNinjaAtk"

EXPOSE 8989

VOLUME /config
VOLUME /usr/local/sma/config
