#!/usr/bin/env bash
apikey="$(grep "<ApiKey>" /config/config.xml | sed "s/\  <ApiKey>//;s/<\/ApiKey>//")"
SonarrUrl="http://127.0.0.1:8989"
scriptpath="/config/sma"
echo "$apikey"
# exec &>> "$scriptpath/MKVTagger.log"

sonarrseriesid="$sonarr_series_id"
sonarrseriesid=573
sonarrepisodefileid="$sonarr_episodefile_id"
sonarrepisodefileid=59319
sonarrseriesdata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/series/$sonarrseriesid")"
sonarrepisodedata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episode?seriesId=$sonarrseriesid" | jq -r ".[] | select(.episodeFileId==$sonarrepisodefileid)")"
sonarrepisodefiledata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episodefile/$sonarrepisodefileid")"
sonarrepisodetitle="$(echo "$sonarrepisodedata" | jq -r ".title")"
sonarrepisodeoverview="$(echo "$sonarrepisodedata" | jq -r ".overview")"
sonarrepisodenumber="$(echo "$sonarrepisodedata" | jq -r ".seasonNumber")"
sonarrepisodeseasonnumber="$(echo "$sonarrepisodedata" | jq -r ".episodeNumber")"
sonarrepisodeairdate="$(echo "$sonarrepisodedata" | jq -r ".airDate")"
sonarrepisodeyear="${sonarrepisodeairdate:0:4}"
sonarrseriestitle="$(echo "$sonarrseriesdata" | jq -r ".title")"
sonarrseriesyear="$(echo "$sonarrseriesdata" | jq -r ".year")"
sonarrseriesseasonepisodecount="$(echo "${sonarrseriesdata}" | jq -r ".seasons | .[] | select(.seasonNumber==$sonarrepisodeseasonnumber) | .statistics.episodeCount")"
sonarrseriesgenre="$(echo "${sonarrseriesdata}" | jq -r ".genres | .[]" | head -n 1)"
sonarrepisodefile="$(echo "$sonarrepisodefiledata" | jq -r ".path")"
sonarrepisodefilepath="$(dirname "$sonarrepisodefile")"
sonarrepisodefilename="$(basename "$sonarrepisodefile")"

sonarrseries="$(echo "$sonarrseriesdata" | jq -r ".title")"
sonarrseries="$(echo "$sonarrseriesdata" | jq -r ".title")"
sonarrseries="$(echo "$sonarrseriesdata" | jq -r ".title")"

echo "$sonarrseriesdata"
echo "$sonarrepisodedata"
echo "$sonarrepisodefiledata"
echo "$sonarrepisodetitle"
echo "$sonarrepisodenumber"
echo "$sonarrepisodeseasonnumber"
echo "$sonarrepisodeoverview"
echo "$sonarrseriestitle"
echo "$sonarrseriesyear"
echo "$sonarrepisodefile"
echo "$sonarrepisodefilename"
echo "$sonarrepisodefilepath"
echo "$sonarrseriesgenre"
echo "$sonarrepisodeyear"
echo "$sonarrseriesseasonepisodecount"

test () {
if [ ${sonarrepisodefile: -4} == ".mkv" ]; then
	echo "Processing :: $sonarrseriestitle :: $sonarrepisodetitle"
	mv "$sonarrepisodefilepath/$sonarrepisodefilename" "$sonarrepisodefilepath/temp.mkv"
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
		-metadata PART_NUMBER="$sonarrepisodenumber" \
		-metadata TOTAL_PARTS="$sonarrseriesseasonepisodecount" \
		-metadata ALBUM="$sonarrseriestitle, Season $sonarrepisodeseasonnumber" \
		-metadata COMMENT="$sonarrepisodeoverview" \
		"$sonarrepisodefilepath/$sonarrepisodefilename" &> /dev/null
	if [ -f "$sonarrepisodefilepath/$sonarrepisodefilename" ]; then
		rm "$sonarrepisodefilepath/temp.mkv"
		echo "Processing :: $sonarrseriestitle :: $sonarrepisodetitle :: Updating File Statistics"
		mkvpropedit "$sonarrepisodefilepath/$sonarrepisodefilename" --add-track-statistics-tags &> /dev/null
		echo "Processing :: $sonarrseriestitle :: $sonarrepisodetitle :: Complete!"
	else
		echo "Processing :: $sonarrseriestitle :: $sonarrepisodetitle :: Failed!"
		mv "$sonarrepisodefilepath/temp.mkv" "$sonarrepisodefilepath/$sonarrepisodefilename"
	fi
fi
}

test
exit 0
