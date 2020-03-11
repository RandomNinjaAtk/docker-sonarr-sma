#!/usr/bin/with-contenv bash

if [ ! -d "/config/sma" ]; then
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
	touch "/config/sma/index.log"
fi
if [ -f "/var/log/sickbeard_mp4_automator/index.log" ]; then
	rm "/var/log/sickbeard_mp4_automator/index.log"
fi
ln -s "/config/sma/index.log" "/var/log/sickbeard_mp4_automator/index.log"

exit 0
