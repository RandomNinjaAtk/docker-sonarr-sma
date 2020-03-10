ARG ffmpeg_tag=snapshot-vaapi
FROM mdhiggins/sonarr-sma:build
LABEL maintainer="RandomNinjaAtk"

EXPOSE 8989

VOLUME /config
VOLUME /usr/local/sma/config

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
COPY extras/ ${SMAPATH}/
COPY root/ /
