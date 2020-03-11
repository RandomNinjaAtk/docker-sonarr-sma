#!/usr/bin/with-contenv bash

if [ ! -d "/config/sma" ]; then
	mkdir -p "/config/sma" && \
	chmod 0777 -R "/config/sma"
fi

if [ ! -f "/config/sma/config/autoProcess.ini" ]; then
	cp "/usr/local/sma/config/autoProcess.ini.sample" "/config/sma/autoProcess.ini" && \
	chmod 0666 "/config/sma"/*  && \
	sed -i "s/codec = aac/codec = libfdk_aac/g" "/config/sma/autoProcess.ini" && \
	sed -i "s/ac3/eac3,ac3,aac,mp3/g" "/config/sma/autoProcess.ini" && \
	sed -i "s/poster/thumb/g" "/config/sma/autoProcess.ini" && \
	sed -i "s/languages = /languages = eng/g" "/config/sma/autoProcess.ini" && \
	sed -i "s/default-language = /default-language = eng/g" "/config/sma/autoProcess.ini" && \
	sed -i "s/burn-subtitles = False/burn-subtitles = forced/g" "/config/sma/autoProcess.ini" && \
	sed -i "s/sort-streams = False/sort-streams = True/g" "/config/sma/autoProcess.ini"
fi

if [ ! -f "/usr/local/sma/config/autoProcess.ini" ]; then
	ln -s "/config/sma/autoProcess.ini" "/usr/local/sma/config/autoProcess.ini"
fi

if [ -f "/var/log/sickbeard_mp4_automator/index.log" ]; then
	rm "/var/log/sickbeard_mp4_automator/index.log"
fi

if [ -f "/config/sma/index.log" ]; then
	rm "/config/sma/index.log"
fi

touch "/config/sma/index.log"
ln -s "/config/sma/index.log" "/var/log/sickbeard_mp4_automator/index.log"

exit 0
