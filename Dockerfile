FROM jrottenberg/ffmpeg:snapshot-vaapi as ffmpeg
FROM linuxserver/sonarr:preview
LABEL maintainer="RandomNinjaAtk"

ENV SMA_PATH /usr/local/sma
ENV UPDATE_SMA FALSE
# converter settings
ENV CONVERTER_OUTPUT_FORMAT="mp4"
ENV CONVERTER_OUTPUT_EXTENSION="mp4"
ENV CONVERTER_PROCESS_SAME_EXTENSIONS=""
ENV CONVERTER_FORCE_CONVERT=""
ENV CONVERTER_PREOPTS=""
ENV CONVERTER_POSTOPTS=""
# metadata settings
ENV METADATA_RELOCATE_MOV=""
ENV METADATA_TAG=""
ENV METADATA_TAG_LANGUAGE=""
ENV METADATA_DOWNLOAD_ARTWORK=""
# video settings
ENV VIDEO_CODEC="h264, x264"
ENV VIDEO_BITRATE=""
ENV VIDEO_CRF=""
ENV VIDEO_CRF_PROFILES=""
ENV VIDEO_PROFILE=""
ENV VIDEO_MAX_LEVEL="0.0"
ENV VIDEO_PIX_FMT=""
# audio settings
ENV AUDIO_CODEC="ac3"
ENV AUDIO_LANGUAGES=""
ENV AUDIO_DEFAULT_LANGUAGE=""
ENV AUDIO_CHANNEL_BITRATE="0"
ENV AUDIO_MAX_CHANNELS="0"
ENV AUDIO_PREFER_MORE_CHANNELS=""
ENV AUDIO_FIRST_STREAM_OF_LANGUAGE=""
ENV AUDIO_MAX_BITRATE=""
ENV AUDIO_DEFAULT_MORE_CHANNELS=""
# universal audio settings
ENV UAUDIO_CODEC=""
ENV UAUDIO_CHANNEL_BITRATE=""
ENV UAUDIO_FIRST_TRACK_ONLY=""
ENV UAUDIO_MOVE_LAST=""
ENV UAUDIO_FIRST_STREAM_ONLY=""
# subtitle settings
ENV SUBTITLE_CODEC=""
ENV SUBTITLE_CODEC_IMAGE_BASED="" 
ENV SUBTITLE_LANGUAGES=""
ENV SUBTITLE_DEFAULT_LANGUAGE=""
ENV SUBTITLE_ENCODING=""
ENV SUBTITLE_BURN_SUBTITLES=""
ENV SUBTITLE_EMBED_SUBS=""
ENV SUBTITLE_FIRST_STREAM_OF_LANGUAGE=""
# plex settings
ENV PLEX_HOST=""
ENV PLEX_PORT="32400"
ENV PLEX_REFRESH="False"
ENV PLEX_TOKEN=""


# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/

# get python3 and git, and install python libraries
RUN \
	apt-get update && \
	apt-get install -y \
		git \
		wget \
		python3 \
		python3-pip && \
	# make directory
	mkdir -p ${SMA_PATH} && \
	# download repo
	git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
	mkdir -p ${SMA_PATH}/config && \
	# create logging file
	mkdir -p ${SMA_PATH}/config && \
	touch ${SMA_PATH}/config/sma.log && \
	chgrp users ${SMA_PATH}/config/sma.log && \
	chmod g+w ${SMA_PATH}/config/sma.log && \
	# install pip, venv, and set up a virtual self contained python environment
	python3 -m pip install --user --upgrade pip && \
	pip3 install -r ${SMA_PATH}/setup/requirements.txt

RUN \
	# ffmpeg
	chgrp users /usr/local/bin/ffmpeg && \
	chgrp users /usr/local/bin/ffprobe && \
	chmod g+x /usr/local/bin/ffmpeg && \
	chmod g+x /usr/local/bin/ffprobe && \
	echo "**** install runtime ****" && \
	apt-get update && \
	apt-get install -y \
		i965-va-driver \
		libexpat1 \
		libgl1-mesa-dri \
		libglib2.0-0 \
		libgomp1 \
		libharfbuzz0b \
		libv4l-0 \
		libx11-6 \
		libxcb1 \
		libxext6 \
		libxml2 \
		libva-drm2 \
		libva2 && \
 	echo "**** clean up ****" && \
	rm -rf \
		/var/lib/apt/lists/* \
		/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
