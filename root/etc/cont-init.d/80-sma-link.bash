#!/usr/bin/with-contenv bash

if [ ! -d "/config/sma/config" ]; then
	mkdir -p "/config/sma" && \
	chmod 0777 -R "/config/sma"
fi

if [ ! -f "/config/sma/config/autoProcess.ini" ]; then
	cp "/usr/local/sma/config/autoProcess.ini.sample" "/config/sma/autoProcess.ini" && \
	chmod 0666 "/config/sma"/*
fi

if [ ! -f "/usr/local/sma/config/autoProcess.ini" ]; then
	ln -s "/config/sma/autoProcess.ini" "/usr/local/sma/config/autoProcess.ini"
fi

if [ ! -f "/config/sma/index.log" ]; then
	ln -s "/var/log/sickbeard_mp4_automator/index.log" "/config/sma/index.log"
fi

exit 0
