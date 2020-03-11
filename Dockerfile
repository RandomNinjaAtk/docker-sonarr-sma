ARG ffmpeg_tag=snapshot-vaapi
FROM mdhiggins/sonarr-sma:build
LABEL maintainer="RandomNinjaAtk"

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
VOLUME /usr/local/sma/config
