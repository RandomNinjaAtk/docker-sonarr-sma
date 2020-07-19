#!/usr/bin/env bash
apikey="$(grep "<ApiKey>" /config/config.xml | sed "s/\  <ApiKey>//;s/<\/ApiKey>//")"
SonarrUrl="http://127.0.0.1:8989"
scriptpath="/config/scripts"
sleep 5
exec &>> "$scriptpath/MKVTagger.log"

sonarrseriesid="$sonarr_series_id"
sonarrepisodefileid="$sonarr_episodefile_id"
sonarrseriesdata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/series/$sonarrseriesid")"
sonarrepisodedata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episode?seriesId=$sonarrseriesid" | jq -r ".[] | select(.episodeFileId==$sonarrepisodefileid)")"
sonarrepisodefiledata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episodefile/$sonarrepisodefileid")"
sonarrepisodetitle="$(echo "$sonarrepisodedata" | jq -r ".title")"
sonarrepisodeoverview="$(echo "$sonarrepisodedata" | jq -r ".overview")"
sonarrepisodeseasonnumber="$(echo "$sonarrepisodedata" | jq -r ".seasonNumber")"
sonarrepisodenumber="$(echo "$sonarrepisodedata" | jq -r ".episodeNumber")"
sonarrepisodeairdate="$(echo "$sonarrepisodedata" | jq -r ".airDate")"
sonarrepisodeyear="${sonarrepisodeairdate:0:4}"
sonarrseriestitle="$(echo "$sonarrseriesdata" | jq -r ".title")"
sonarrseriesyear="$(echo "$sonarrseriesdata" | jq -r ".year")"
sonarrseriesseasonepisodecount="$(echo "${sonarrseriesdata}" | jq -r ".seasons | .[] | select(.seasonNumber==$sonarrepisodeseasonnumber) | .statistics.episodeCount")"
sonarrseriesgenre="$(echo "${sonarrseriesdata}" | jq -r ".genres | .[]" | head -n 1)"
sonarrepisodefile="$(echo "$sonarrepisodefiledata" | jq -r ".path")"
sonarrepisodefilepath="$(dirname "$sonarrepisodefile")"
sonarrepisodefilename="$(basename "$sonarrepisodefile")"
sonarrepisodefilenamenoext="$(basename "$sonarrepisodefilename" .mkv)"
sonarrepisodethumbnail="$sonarrepisodefilenamenoext-thumb.jpg"

if [ ${sonarrepisodefile: -4} == ".mkv" ]; then
	echo "Processing :: $sonarrseriestitle :: Season $sonarrepisodeseasonnumber :: Episode $sonarrepisodenumber :: $sonarrepisodetitle"
	mv "$sonarrepisodefilepath/$sonarrepisodefilename" "$sonarrepisodefilepath/temp.mkv"
	if [ -f "$sonarrepisodefilepath/$sonarrepisodethumbnail" ]; then
		cp "$sonarrepisodefilepath/$sonarrepisodethumbnail" "$sonarrepisodefilepath/cover.jpg"
		ffmpeg -y \
			-i "$sonarrepisodefilepath/temp.mkv" \
			-c:v copy \
			-c:a copy \
			-c:s copy \
			-metadata TITLE="${sonarrepisodetitle}" \
			-metadata DATE_RELEASE="$sonarrepisodeyear" \
			-metadata DATE="$sonarrepisodeyear" \
			-metadata YEAR="$sonarrepisodeyear" \
			-metadata GENRE="$sonarrseriesgenre" \
			-metadata ALBUM="$sonarrseriestitle, Season $sonarrepisodeseasonnumber" \
			-metadata COMMENT="$sonarrepisodeoverview" \
			-attach "$sonarrepisodefilepath/cover.jpg" -metadata:s:t mimetype=image/jpeg \
		"$sonarrepisodefilepath/$sonarrepisodefilename" &> /dev/null
	else
		ffmpeg -y \
			-i "$sonarrepisodefilepath/temp.mkv" \
			-c:v copy \
			-c:a copy \
			-c:s copy \
			-metadata TITLE="${sonarrepisodetitle}" \
			-metadata DATE_RELEASE="$sonarrepisodeyear" \
			-metadata DATE="$sonarrepisodeyear" \
			-metadata YEAR="$sonarrepisodeyear" \
			-metadata GENRE="$sonarrseriesgenre" \
			-metadata ALBUM="$sonarrseriestitle, Season $sonarrepisodeseasonnumber" \
			-metadata COMMENT="$sonarrepisodeoverview" \
		"$sonarrepisodefilepath/$sonarrepisodefilename" &> /dev/null
	fi
	if [ -f "$sonarrepisodefilepath/$sonarrepisodefilename" ]; then
		if [ -f "$sonarrepisodefilepath/temp.mkv" ]; then
			rm "$sonarrepisodefilepath/temp.mkv"
		fi
		if [ -f "$sonarrepisodefilepath/cover.jpg" ]; then
			rm "$sonarrepisodefilepath/cover.jpg"
		fi
		echo "Processing :: $sonarrseriestitle :: Season $sonarrepisodeseasonnumber :: Episode $sonarrepisodenumber :: $sonarrepisodetitle :: Updating File Statistics"
		mkvpropedit "$sonarrepisodefilepath/$sonarrepisodefilename" --add-track-statistics-tags &> /dev/null
		echo "Processing :: $sonarrseriestitle :: Season $sonarrepisodeseasonnumber :: Episode $sonarrepisodenumber :: $sonarrepisodetitle :: Complete!"
	else
		echo "Processing :: $sonarrseriestitle :: Season $sonarrepisodeseasonnumber :: Episode $sonarrepisodenumber :: $sonarrepisodetitle :: Failed!"
		mv "$sonarrepisodefilepath/temp.mkv" "$sonarrepisodefilepath/$sonarrepisodefilename"
		if [ -f "$sonarrepisodefilepath/cover.jpg" ]; then
			rm "$sonarrepisodefilepath/cover.jpg"
		fi
	fi
fi

exit 0
