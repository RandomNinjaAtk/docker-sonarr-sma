ARG ffmpeg_tag=snapshot-vaapi
FROM mdhiggins/sonarr-sma:build
LABEL maintainer="RandomNinjaAtk"

RUN \
	mkdir -p /config/sma/config && \ 
	ln -sf "/config/sma/config" "/usr/local/sma/config" && \
	ln -sf "/var/log/sickbeard_mp4_automator/index.log" "/config/sma/index.log"

EXPOSE 8989

VOLUME /config
VOLUME /usr/local/sma/config
