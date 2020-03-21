FROM jrottenberg/ffmpeg:snapshot-vaapi as ffmpeg
FROM linuxserver/sonarr:preview
LABEL maintainer="RandomNinjaAtk"

ENV SMA_PATH /usr/local/sma
ENV UPDATE_SMA FALSE
ENV SMA_APP Sonarr
# converter settings
ENV CONVERTER_THREADS="0"
ENV CONVERTER_OUTPUT_FORMAT="mp4"
ENV CONVERTER_OUTPUT_EXTENSION="mp4"
ENV CONVERTER_SORT_STREAMS="False"
ENV CONVERTER_PROCESS_SAME_EXTENSIONS="False"
ENV CONVERTER_FORCE_CONVERT="False"
ENV CONVERTER_PREOPTS=""
ENV CONVERTER_POSTOPTS=""
# permissions
ENV PERMISSIONS_CHMOD="0666"
# metadata settings
ENV METADATA_RELOCATE_MOV="True"
ENV METADATA_TAG="True"
ENV METADATA_TAG_LANGUAGE="eng"
ENV METADATA_DOWNLOAD_ARTWORK="thumb"
# video settings
ENV VIDEO_CODEC="h264, x264"
ENV VIDEO_BITRATE="0"
ENV VIDEO_CRF="-1"
ENV VIDEO_CRF_PROFILES=""
ENV VIDEO_MAX_WIDTH="0"
ENV VIDEO_PROFILE=""
ENV VIDEO_MAX_LEVEL="0.0"
ENV VIDEO_PIX_FMT=""
# audio settings
ENV AUDIO_CODEC="ac3"
ENV AUDIO_LANGUAGES=""
ENV AUDIO_DEFAULT_LANGUAGE=""
ENV AUDIO_FIRST_STREAM_OF_LANGUAGE="False"
ENV AUDIO_CHANNEL_BITRATE="128"
ENV AUDIO_MAX_BITRATE="0"
ENV AUDIO_MAX_CHANNELS="0"
ENV AUDIO_PREFER_MORE_CHANNELS="True"
ENV AUDIO_DEFAULT_MORE_CHANNELS="True"
ENV AUDIO_COPY_ORIGINAL="False"
# universal audio settings
ENV UAUDIO_CODEC="aac"
ENV UAUDIO_CHANNEL_BITRATE="128"
ENV UAUDIO_FIRST_STREAM_ONLY="False"
ENV UAUDIO_MOVE_AFTER="False"
ENV UAUDIO_FILTER=""
# subtitle settings
ENV SUBTITLE_CODEC="mov_text"
ENV SUBTITLE_CODEC_IMAGE_BASED="" 
ENV SUBTITLE_LANGUAGES=""
ENV SUBTITLE_DEFAULT_LANGUAGE=""
ENV SUBTITLE_FIRST_STREAM_OF_LANGUAGE="False"
ENV SUBTITLE_ENCODING=""
ENV SUBTITLE_BURN_SUBTITLES=""
ENV SUBTITLE_EMBED_SUBS=""
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
