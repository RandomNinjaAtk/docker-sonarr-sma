ARG ffmpeg_tag=snapshot-vaapi
FROM mdhiggins/sonarr-sma:build
LABEL maintainer="RandomNinjaAtk"

RUN \
	apt-get update -y && \
	apt-get install -y --no-install-recommends libva-drm2 libva2 i965-va-driver && \
	rm -rf /var/lib/apt/lists

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
VOLUME /usr/local/sma/config
