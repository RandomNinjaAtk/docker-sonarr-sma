#!/usr/bin/env bash
sonarrApiKey="$(grep "<ApiKey>" /config/config.xml | sed "s/\  <ApiKey>//;s/<\/ApiKey>//")"

if [ "$sonarr_eventtype" == "Test" ]; then
	log "Tested"
	exit 0	
fi

seriesId=$sonarr_series_id
seriesData=$(curl -s "http://localhost:8989/api/v3/series/$seriesId?apikey=$sonarrApiKey")
seriesTitle=$(echo $seriesData | jq -r ".title")
seriesType=$(echo $seriesData | jq -r ".seriesType")
seriesEpisodeData=$(curl -s "http://localhost:8989/api/v3/episode?seriesId=$seriesId&apikey=$sonarrApiKey")
seriesEpisodeIds=$(echo "$seriesEpisodeData" | jq -r " . | sort_by(.airDate) | reverse | .[] | select(.hasFile==true) | .id")
seriesEpisodeIdsCount=$(echo "$seriesEpisodeIds" | wc -l)

# Verify series is marked as "daily" type by sonarr, skip if not...
if [ $seriesType != "daily" ]; then
	echo "$seriesTitle (ID:$seriesId) :: TYPE :: $seriesType :: ERROR :: Non-daily series, skipping..."
	exit
fi

# Skip processing if less than 14 episodes were found to be downloaded
if [ $seriesEpisodeIdsCount -lt 14 ]; then
	echo "$seriesTitle (ID:$seriesId) :: TYPE :: $seriesType :: ERROR :: Series has not exceeded 14 downloaded episodes ($seriesEpisodeIdsCount files found), skipping..."
	exit
fi

# Begin processing "daily" series type
if [ $seriesType == daily ]; then
	seriesEpisodeData=$(curl -s "http://localhost:8989/api/v3/episode?seriesId=$seriesId&apikey=$sonarrApiKey")
	seriesEpisodeIds=$(echo "$seriesEpisodeData"| jq -r " . | sort_by(.airDate) | reverse | .[] | select(.hasFile==true) | .id")
	processId=0
	seriesRefreshRequired=false
	for id in $seriesEpisodeIds; do
		processId=$(( $processId + 1 ))
		if [ $processId -gt 14 ]; then
			episodeData=$(curl -s "http://localhost:8989/api/v3/episode/$id?apikey=$sonarrApiKey")
			episodeSeriesId=$(echo "$episodeData" | jq -r ".seriesId")
			episodeTitle=$(echo "$episodeData" | jq -r ".title")
			episodeSeasonNumber=$(echo "$episodeData" | jq -r ".seasonNumber")
			episodeNumber=$(echo "$episodeData" | jq -r ".episodeNumber")
			episodeAirDate=$(echo "$episodeData" | jq -r ".airDate")
			episodeFileId=$(echo "$episodeData" | jq -r ".episodeFileId")
			
			# Unmonitor downloaded episode if greater than 14 downloaded episodes
			echo "$seriesTitle (ID:$episodeSeriesId) :: TYPE :: $seriesType :: S${episodeSeasonNumber}E${episodeNumber} :: $episodeAirDate :: $episodeTitle :: Unmonitored Episode ID :: $id"
			umonitorEpisode=$(curl -s "http://localhost:8989/api/v3/episode/monitor?apikey=$sonarrApiKey" -X PUT --data-raw "{\"episodeIds\":[$id],\"monitored\":false}")			
			
			# Delete downloaded episode if greater than 14 downloaded episodes
			echo "$seriesTitle (ID:$episodeSeriesId) :: TYPE :: $seriesType :: S${episodeSeasonNumber}E${episodeNumber} :: $episodeAirDate :: $episodeTitle :: Deleted File ID :: $episodeFileId"
			deleteFile=$(curl -s "http://localhost:8989/api/v3/episodefile/$episodeFileId?apikey=$sonarrApiKey" -X DELETE)
			seriesRefreshRequired=true
		else
			# Skip if less than required 14 downloaded episodes exist
			echo "$seriesTitle (ID:$episodeSeriesId) :: TYPE ::  $seriesType :: Skipping Episode ID :: $id"
		fi
	done
	if [ "$seriesRefreshRequired" = "true" ]; then
		# Refresh Series after changes
		echo "$seriesTitle (ID:$episodeSeriesId) :: TYPE :: $seriesType :: Refresh Series"
		refreshSeries=$(curl -s "http://localhost:8989/api/v3/command?apikey=$sonarrApiKey" -X POST --data-raw "{\"name\":\"RefreshSeries\",\"seriesId\":$episodeSeriesId}")
	fi
fi

exit
