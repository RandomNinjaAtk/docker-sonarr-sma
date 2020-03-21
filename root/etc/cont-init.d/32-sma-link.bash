#!/usr/bin/with-contenv bash

# create config directory
if [ ! -d "/config/sma" ]; then
	mkdir -p "/config/sma" && \
	chmod 0777 -R "/config/sma"
fi

# delete existing config
if [ -f "/usr/local/sma/config/autoProcess.ini" ]; then
	rm "/usr/local/sma/config/autoProcess.ini"
fi

# import new config, if does not exist
if [ ! -f "/config/sma/autoProcess.ini" ]; then
	cp "/usr/local/sma/setup/autoProcess.ini.sample" "/usr/local/sma/config/autoProcess.ini"
fi

# remove sickbeard_mp4_automator log if exists
if [ -f "/config/sma/sma.log" ]; then
	rm "/config/sma/sma.log"
fi

if [ -f "/config/sma/sma.log" ]; then
	rm "/usr/local/sma/config/sma.log"
fi

# create sma log file
touch "/config/sma/sma.log" && \

# link sma log file
ln -s "/config/sma/sma.log" "/usr/local/sma/config/sma.log" && \

# set permissions
chmod 0666 "/config/sma"/*

exit 0
