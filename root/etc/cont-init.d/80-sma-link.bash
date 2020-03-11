#!/usr/bin/with-contenv bash

if [ ! -d "/config/sma/config" ]; then
	mkdir -p "/config/sma/config" && \
	chmod 0777 -R "/config/sma/config"
fi

if [ ! -f "/config/sma/config/autoProcess.ini" ]; then
	cp "/usr/local/sma/config/autoProcess.ini.sample" "/config/sma/config/autoProcess.ini" && \
	chmod 0666 "/config/sma/config"/*
fi

ln -s "/config/sma/config/autoProcess.ini" "/usr/local/sma/config/autoProcess.ini"
ln -s "/var/log/sickbeard_mp4_automator/index.log" "/config/sma/index.log"

exit 0
