#!/usr/bin/with-contenv bash

if [ ! -d "/config/sma/config" ]; then
	mkdir -p "/config/sma/config" && \
	chmod 0777 -R "/config/sma/config"
fi

ln -sf "/config/sma/config" "/usr/local/sma/config" && \
ln -sf "/var/log/sickbeard_mp4_automator/index.log" "/config/sma/index.log" && \

if [ ! -f "/config/sma/config/autoProcess.ini" ]; then
	mv "/config/sma/config/autoProcess.ini.sample" "/config/sma/config/autoProcess.ini" && \
	chmod 0666 "/config/sma/config"
fi

exit 0
