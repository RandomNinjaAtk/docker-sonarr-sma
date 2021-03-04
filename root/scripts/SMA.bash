#!/usr/bin/env bash
exec &>> "/config/scripts/sma.log"
if [ $sonarr_eventtype == "Test" ]; then
	echo "Tested"
	exit 0	
fi

extension="${sonarr_episodefile_path##*.}"

if [ "$extension" == "mp4" ]; then
	echo "================================================================================================================"
	echo "Processing Event: $sonarr_eventtype"
	echo "Series: $sonarr_series_title ($sonarr_series_tvdbid)"
	echo "Series Type: $sonarr_series_type"
	echo "File: $sonarr_episodefile_path"
	echo "Sending to SMA..."
	echo "================================================================================================================"
	
	if [ ! -f "$sonarr_episodefile_path" ]; then
		echo "file not found sleeping..."
		sleep 2
	fi

	if [ -f /usr/local/sma/config/sma.log ]; then
		rm /usr/local/sma/config/sma.log
	fi
	
	if [ -f "/config/scripts/sma.ini" ]; then
		smaconfig="/config/scripts/sma.ini"
	else
		echo "error, no config found"
		exit 0
	fi
	# Manual run of Sickbeard MP4 Automator
	python3 /usr/local/sma/manual.py --config "$smaconfig" -i "$sonarr_episodefile_path" -a -tvdb $sonarr_series_tvdbid
	echo "================================================================================================================"
	echo "DONE"
	echo "================================================================================================================"
fi

exit $?
