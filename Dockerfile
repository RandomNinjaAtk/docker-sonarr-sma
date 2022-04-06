FROM linuxserver/sonarr:latest
LABEL maintainer="RandomNinjaAtk"

ENV SMA_PATH /usr/local/sma
ENV UPDATE_SMA FALSE
ENV SMA_APP Sonarr

RUN \
	echo "************ install packages ************" && \
	apk add  -U --update --no-cache \
		jq \
		git \
		wget \
		mkvtoolnix \
		python3 \
		py3-pip \
		ffmpeg && \
	echo "************ setup SMA ************" && \
	echo "************ setup directory ************" && \
	mkdir -p ${SMA_PATH} && \
	echo "************ download repo ************" && \
	git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
	mkdir -p ${SMA_PATH}/config && \
	echo "************ create logging file ************" && \
	mkdir -p ${SMA_PATH}/config && \
	touch ${SMA_PATH}/config/sma.log && \
	chgrp users ${SMA_PATH}/config/sma.log && \
	chmod g+w ${SMA_PATH}/config/sma.log && \
	echo "************ install pip dependencies ************" && \
	python3 -m pip install --user --upgrade pip && \	
	pip3 install -r ${SMA_PATH}/setup/requirements.txt && \
	echo "************ install python packages ************" && \
	python3 -m pip install --no-cache-dir -U \
		yq 
	
WORKDIR /

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
