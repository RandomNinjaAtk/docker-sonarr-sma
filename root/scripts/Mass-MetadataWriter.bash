#!/usr/bin/env bash
apikey="$(grep "<ApiKey>" /config/config.xml | sed "s/\  <ApiKey>//;s/<\/ApiKey>//")"
SonarrUrl="http://127.0.0.1:8989"
themoviedbapikey="3b7751e3179f796565d88fdb2fcdf426"

log () {
	m_time=`date "+%F %T"`
	echo $m_time" "$1
}

if [ "$sonarr_eventtype" == "Test" ]; then
	log "Tested"
	exit 0
fi

sonarrseries="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/series")"
sonarrseriesidscount=$(echo "$sonarrseries" | jq -r ".[].id" | wc -l)
sonarrseriesids=($(echo "$sonarrseries" | jq -r ".[].id"))
log "############## NFO Writer"

SeriesNFOWriter () {
	sonarrseriesdata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/series/$sonarr_series_id")"
	sonarrseriesepisodes="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episode?seriesId=$sonarr_series_id")"
	episodefileidscount=$(echo "$sonarrseriesepisodes" | jq -r ".[] | select(.hasFile=="true") | .episodeFileId" | wc -l)
	episodefileids=($(echo "$sonarrseriesepisodes" | jq -r ".[] | select(.hasFile=="true") | .episodeFileId"))
	sonarrshowpath="$(echo "$sonarrseriesdata" | jq -r ".path")"
	sonarrshowtitle="$(echo "$sonarrseriesdata" | jq -r ".title")"
	sonarrseriestitle="$(echo "$sonarrseriesdata" | jq -r ".title")"
	sonarrshowsorttitle="$(echo "$sonarrseriesdata" | jq -r ".sortTitle")"
	sonarrepisodetvdbId="$(echo "$sonarrseriesdata" | jq -r ".tvdbId")"
	sonarrshowmpaa="$(echo "$sonarrseriesdata" | jq -r ".certification")"
	sonarrshowoverview="$(echo "$sonarrseriesdata" | jq -r ".overview")"
	sonarrshowimdbid="$(echo "$sonarrseriesdata" | jq -r ".imdbId")"
	sonarrshowyear="$(echo "$sonarrseriesdata" | jq -r ".year")"
	sonarrshownetwork="$(echo "$sonarrseriesdata" | jq -r ".network")"
	sonarr_series_runtime="$(echo "${sonarrseriesdata}" | jq -r ".runtime")"
	sonarrshowlocalposter="MediaCover/${sonarrseriesid}/poster.jpg"
	sonarr_series_seasonNumbers=($(echo "${sonarrseriesdata}" | jq -r ".seasons[].seasonNumber"))
	sonarrshowposter=$(echo "${sonarrseriesdata}" | jq -r ".images[] | select(.coverType==\"poster\") | .remoteUrl")
	sonarrshowlocalfanart="MediaCover/${sonarrseriesid}/fanart.jpg"
	sonarrshowfanart=$(echo "${sonarrseriesdata}" | jq -r ".images[] | select(.coverType==\"fanart\") | .remoteUrl")
	sonarrshowlocalbanner="MediaCover/${sonarrseriesid}/banner.jpg"
	sonarrshowbanner=$(echo "${sonarrseriesdata}" | jq -r ".images[] | select(.coverType==\"banner\") | .remoteUrl")

	# Season Data
	# themoviedbshowseasondata=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/season/${sonarrepisodeseasonnumber}?api_key=$themoviedbapikey" | jq -r ".")
	# themoviedbshowseasonvideos=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/season/${sonarrepisodeseasonnumber}/videos?api_key=$themoviedbapikey" | jq -r ".")

	nfo="$sonarrshowpath/tvshow.nfo"
	log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle"
	if [ ! -d "$sonarrshowpath" ]; then
		log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Show folder does not exist, skipping..."
		return
	fi
	if [  -f "$nfo" ]; then
		if cat "$nfo" | grep "tmdb" | read; then
			sleep 0.01
			themoviedbid=$(cat "$nfo" | xq . | jq -r ".tvshow.uniqueid[] | select(.\"@type\"==\"tmdb\") | .\"#text\"")
		else
			touch -d "2 hours ago" "$nfo"
			themoviedbid="unkown"
		fi

		if find "$nfo" -name "tvshow.nfo" -type f -mtime +30 | read; then
			log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Show :: NFO detected, removing..."
			rm "$nfo"
		else
			log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Show :: Detected NFO doesn't require update..."
		fi
	fi

	if [ ! -f "$nfo" ]; then

		# Get show data from themoviedb via API
		if [ "$themoviedbid" != "unknown" ]; then
			themoviedbid=$(curl -s "https://api.themoviedb.org/3/find/$sonarrepisodetvdbId?api_key=$themoviedbapikey&external_source=tvdb_id" | jq -r ".tv_results[].id")
		fi
		themoviedbshowdata=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid?api_key=$themoviedbapikey" | jq -r ".")
		themoviedbshowcredits=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/aggregate_credits?api_key=$themoviedbapikey" | jq -r ".")
		# themoviedbshowvideos=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/videos?api_key=$themoviedbapikey" | jq -r ".")
		themoviedbshowdata=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid?api_key=$themoviedbapikey" | jq -r ".")
		themoviedbshowcredits=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/aggregate_credits?api_key=$themoviedbapikey" | jq -r ".")
		tmdb_keywords=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/keywords?api_key=${themoviedbapikey}")
		tmbd_original_name=$(echo "$themoviedbshowdata" | jq -r ".original_name")
		tmbd_tagline=$(echo "$themoviedbshowdata" | jq -r ".tagline")
		tmdb_vote_average=$(echo "$themoviedbshowdata" | jq -r ".vote_average")
		tmdb_vote_count=$(echo "$themoviedbshowdata" | jq -r ".vote_count")
		tmdb_poster_path=$(echo "$themoviedbshowdata" | jq -r ".poster_path")
		tmdb_backdrop_path=$(echo "$themoviedbshowdata" | jq -r ".backdrop_path")
		# Extract elements from API data
		sonarrseriespremiered="$(echo "${themoviedbshowdata}" | jq -r ".first_air_date")"
		sonarrseriesstatus="$(echo "${themoviedbshowdata}" | jq -r ".status")"
		sonarrseriestagline="$(echo "${themoviedbshowdata}" | jq -r ".tagline")"
		sonarrseriesepisodecount="$(echo "${themoviedbshowdata}" | jq -r ".number_of_episodes")"
		minimumcount=$(( $sonarrseriesepisodecount*50/100 ))
		OLDIFS="$IFS"
		IFS=$'\n'
		tmdb_keywords_names=($(echo "$tmdb_keywords" | jq -r ".results[].name"))
		sonarrseriesgenres=($(echo "${themoviedbshowdata}" | jq -r ".genres[] | .name"))
		tmdb_studios=($(echo "${themoviedbshowdata}" | jq -r ".production_companies[].name"))

		IFS="$OLDIFS"
		sonarrshowcast=($(echo "${themoviedbshowcredits}" | jq -r ".cast[] | select(.total_episode_count>=$minimumcount) | .id"))
		sonarrshowseasons=($(echo "${themoviedbshowdata}" | jq -r ".seasons[] | .id"))

		# Write Show NFO
		log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Show :: Writing NFO..."

		echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" >> "$nfo"
		echo "<tvshow>" >> "$nfo"
		echo "	<title>$sonarrshowtitle</title>" >> "$nfo"
		echo "	<originaltitle>$tmbd_original_name</originaltitle>" >> "$nfo"
		echo "	<sorttitle>$sonarrshowsorttitle</sorttitle>" >> "$nfo"
		echo "	<ratings>" >> "$nfo"
		echo "	    <rating name=\"themoviedb\" max=\"10\" default=\"true\">" >> "$nfo"
		echo "	    	<value>$tmdb_vote_average</value>" >> "$nfo"
		echo "	    	<votes>$tmdb_vote_count</votes>" >> "$nfo"
		echo "		</rating>" >> "$nfo"
		echo "	</ratings>" >> "$nfo"
		echo "	<plot>$sonarrshowoverview</plot>" >> "$nfo"
		echo "	<tagline>$sonarrseriestagline</tagline>" >> "$nfo"
		echo "	<runtime>$sonarr_series_runtime</runtime>" >> "$nfo"
		echo "	<userrating></userrating>" >> "$nfo"
		if [ "$tmdb_poster_path" != "null" ]; then
			echo "	<thumb aspect=\"poster\">https://image.tmdb.org/t/p/original$tmdb_poster_path</thumb>" >> "$nfo"
		fi
		echo "	<thumb aspect=\"banner\">$sonarrshowbanner</thumb>" >> "$nfo"
		for id in ${!sonarr_series_seasonNumbers[@]}; do
			season_number="${sonarr_series_seasonNumbers[$id]}"
			tmdb_season_poster_path=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/season/$season_number?api_key=${themoviedbapikey}" | jq -r ".poster_path")
			if [ "$tmdb_season_poster_path" != "null" ]; then
				echo "	<thumb aspect=\"poster\" season=\"$season_number\" type=\"season\">https://image.tmdb.org/t/p/original${tmdb_season_poster_path}</thumb>" >> "$nfo"
			fi
		done
		echo "	<fanart>" >> "$nfo"
		if [ "$tmdb_backdrop_path" != "null" ]; then
			echo "	    <thumb>https://image.tmdb.org/t/p/original$tmdb_backdrop_path</thumb>" >> "$nfo"
		else
			echo "	    <thumb/>" >> "$nfo"
		fi
		echo "	</fanart>" >> "$nfo"
		echo "	<mpaa>$sonarrshowmpaa</mpaa>" >> "$nfo"
		# TinyMediaManager style
		echo "	<episodeguide>" >> "$nfo"
		echo "		<url cache=\"auth.json\" post=\"yes\">https://api.thetvdb.com/login?{\"apikey\":\"439DFEBA9D3059C6\",\"id\":$sonarrepisodetvdbId}|Content-Type=application/json</url>" >> "$nfo"
		echo "	</episodeguide>" >> "$nfo"
		# sonarr style
		# echo "	<episodeguide>" >> "$nfo"
		# echo "		<url>http://www.thetvdb.com/api/1D62F2F90030C444/series/355567/all/en.zip</url>" >> "$nfo"
		# echo "	</episodeguide>" >> "$nfo"
		# echo "	<episodeguideurl>http://www.thetvdb.com/api/1D62F2F90030C444/series/355567/all/en.zip</episodeguideurl>" >> "$nfo"
		echo "	<id>$sonarrepisodetvdbId</id>" >> "$nfo"
		echo "	<imdbid>$sonarrshowimdbid</imdbid>" >> "$nfo"
		echo "    <uniqueid type=\"tvdb\" default=\"true\">$sonarrepisodetvdbId</uniqueid>" >> "$nfo"
		echo "    <uniqueid type=\"tmdb\" default=\"false\">$themoviedbid</uniqueid>" >> "$nfo"
		echo "    <uniqueid type=\"imdb\" default=\"false\">$sonarrshowimdbid</uniqueid>" >> "$nfo"
		for genre in ${!sonarrseriesgenres[@]}; do
			seriesgenre="${sonarrseriesgenres[$genre]}"
			echo "	<genre>$seriesgenre</genre>" >> "$nfo"
		done
		if [ ! -z "$tmdb_keywords_names" ]; then
		for keyword in ${!tmdb_keywords_names[@]}; do
				name="${tmdb_keywords_names[$keyword]}"
				echo "	<tag>$name</tag>" >> "$nfo"
			done
		else
			echo "	<tag/>" >> "$nfo"
		fi
		echo "    <premiered>$sonarrseriespremiered</premiered>" >> "$nfo"
		echo "    <year>$sonarrshowyear</year>" >> "$nfo"
		echo "    <status>$sonarrseriesstatus</status>" >> "$nfo"
		echo "	<studio>$sonarrshownetwork</studio>" >> "$nfo"
		if [ ! -z "$tmdb_studios" ]; then
			for studio in ${!tmdb_studios[@]}; do
				name="${tmdb_studios[$studio]}"
				echo "	<studio>$name</studio>" >> "$nfo"
			done
		else
			echo "	<studio/>" >> "$nfo"
		fi
		for id in ${!sonarrshowcast[@]}; do
			castid="${sonarrshowcast[$id]}"
			name="$(echo "${themoviedbshowcredits}" | jq -r ".cast[] | select(.id==$castid) | .name")"
			order=$(echo "${themoviedbshowcredits}" | jq -r ".cast[] | select(.id==$castid) | .order")
			OLDIFS="$IFS"
			IFS=$'\n'
			characters=($(echo "${themoviedbshowcredits}" | jq -r ".cast[]  | select(.id==$castid) | .roles[].character"))
			IFS="$OLDIFS"
			thumb=$(echo "${themoviedbshowcredits}" | jq -r ".cast[]  | select(.id==$castid) | .profile_path")
			echo "	<actor>" >> "$nfo"
			echo "		<name>$name</name>" >> "$nfo"
			for role in ${!characters[@]}; do
				name="${characters[$role]}"
				echo "		<role>$name</role>" >> "$nfo"
			done
			echo "		<order>$order</order>" >> "$nfo"
			if [ ! "$thumb" == null ]; then
				echo "		<thumb>https://www.themoviedb.org/t/p/original${thumb}</thumb>" >> "$nfo"
			else
				echo "		<thumb/>" >> "$nfo"
			fi
			echo "		<profile>https://www.themoviedb.org/person/$castid</profile>" >> "$nfo"
			echo "		<tmdbid>$castid</tmdbid>" >> "$nfo"
			echo "	</actor>" >> "$nfo"
		done
		for id in ${!sonarrshowseasons[@]}; do
			seasonid="${sonarrshowseasons[$id]}"
			season_name="$(echo "${themoviedbshowdata}" | jq -r ".seasons[] | select(.id==$seasonid) | .name")"
			season_number="$(echo "${themoviedbshowdata}" | jq -r ".seasons[] | select(.id==$seasonid) | .season_number")"
			echo "    <namedseason number=\"$season_number\">$season_name</namedseason>" >> "$nfo"
		done
		echo "</tvshow>" >> "$nfo"
		tidy -w 2000 -i -m -xml "$nfo" &>/dev/null

		if [ -f "$nfo" ]; then
			log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Show :: Writing Complete"
		fi
	fi
}

EpisodeNFOWriter () {
	sonarrepisodedata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episode?seriesId=$sonarr_series_id" | jq -r ".[] | select(.episodeFileId==$sonarr_episodefile_id)")"
	sonarrepisodefiledata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episodefile/$sonarr_episodefile_id")"
	sonarrepisodeseasonnumber="$(echo "$sonarrepisodedata" | jq -r ".seasonNumber")"
	sonarrepisodenumber="$(echo "$sonarrepisodedata" | jq -r ".episodeNumber")"
	sonarrepisodetitle="$(echo "${sonarrepisodedata}" | jq -r ".title")"
	sonarrepisodeoverview="$(echo "$sonarrepisodedata" | jq -r ".overview")"
	sonarrepisodeairdate="$(echo "$sonarrepisodedata" | jq -r ".airDate")"
	sonarrepisodefile="$(echo "$sonarrepisodefiledata" | jq -r ".path")"
	sonarrepisoderuntime="$(echo "$sonarrepisodefiledata" | jq -r ".mediaInfo.runTime")"
	sonarrepisoderuntime=${sonarrepisoderuntime:0:2}
	sonarrepisodefolderpath="$(dirname "$sonarrepisodefile")"
	sonarrepisodefilename="$(basename "$sonarrepisodefile")"
	sonarrepisodefilenamenoext="${sonarrepisodefilename%.*}"
	sonarrepisodefilenamethumb="${sonarrepisodefile%.*}-thumb.jpg"

	nfo="${sonarrepisodefolderpath}/${sonarrepisodefilenamenoext}.nfo"
	if [ -f "$nfo" ]; then
		rm "$nfo"
	fi

	# Episode data

	themoviedbshowepisodedata=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/season/${sonarrepisodeseasonnumber}/episode/${sonarrepisodenumber}?api_key=$themoviedbapikey" | jq -r ".")
	themoviedbshowepisodecredits=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/season/${sonarrepisodeseasonnumber}/episode/${sonarrepisodenumber}/credits?api_key=$themoviedbapikey" | jq -r ".")
	OLDIFS="$IFS"
	IFS=$'\n'
	sonarrepisodedirectors=($(echo "${themoviedbshowepisodecredits}" | jq -r ".crew[] | select(.job==\"Director\") | .name"))
	sonarrepisodewriters=($(echo "${themoviedbshowepisodecredits}" | jq -r ".crew[] | select(.job==\"Writer\") | .name"))
	IFS="$OLDIFS"
	sonarrepisodecast=($(echo "${themoviedbshowepisodecredits}" | jq -r ".cast[] | .id"))
	sonarrepisodeguestcast=($(echo "${themoviedbshowepisodecredits}" | jq -r ".guest_stars[] | .id"))
	sonarrepisodeid=$(echo "${themoviedbshowepisodedata}" | jq -r ".id")
	sonarrepisodethumb=$(echo "${themoviedbshowepisodedata}" | jq -r ".still_path")


	# Write Episode NFO
	log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Episode $episodeprocessid of $episodefileidscount :: $sonarrepisodetitle :: Writing NFO..."
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" >> "$nfo"
	echo "<episodedetails>" >> "$nfo"
	echo "    <title>$sonarrepisodetitle</title>" >> "$nfo"
	echo "    <showtitle>$sonarrshowtitle</showtitle>" >> "$nfo"
	echo "    <userrating></userrating>" >> "$nfo"
	echo "    <season>$sonarrepisodeseasonnumber</season>" >> "$nfo"
	echo "    <episode>$sonarrepisodenumber</episode>" >> "$nfo"
	echo "    <plot>$sonarrepisodeoverview</plot>" >> "$nfo"
	#echo "    <runtime>$sonarrepisoderuntime</runtime>" >> "$nfo"
	if [ -f "$sonarrepisodefilenamethumb" ]; then
		echo "    <thumb>${sonarrepisodefilenamenoext}-thumb.jpg</thumb>" >> "$nfo"
	else
		echo "    <thumb>https://www.themoviedb.org/t/p/original/$sonarrepisodethumb</thumb>" >> "$nfo"
	fi
	echo "    <uniqueid type=\"tmdb\" default=\"true\">$sonarrepisodeid</uniqueid>" >> "$nfo"
	for writer in ${!sonarrepisodewriters[@]}; do
		writername="${sonarrepisodewriters[$writer]}"
		echo "	<credits>$writername</credits>" >> "$nfo"
	done
	for director in ${!sonarrepisodedirectors[@]}; do
		directorname="${sonarrepisodedirectors[$director]}"
		echo "	<director>$directorname</director>" >> "$nfo"
	done
	echo "    <aired>$sonarrepisodeairdate</aired>" >> "$nfo"
	for id in ${!sonarrepisodecast[@]}; do
		castid="${sonarrepisodecast[$id]}"
		name="$(echo "${themoviedbshowepisodecredits}" | jq -r ".cast[] | select(.id==$castid) | .name")"
		order=$(echo "${themoviedbshowepisodecredits}" | jq -r ".cast[] | select(.id==$castid) | .order")
		OLDIFS="$IFS"
		IFS=$'\n'
		characters=($(echo "${themoviedbshowepisodecredits}" | jq -r ".cast[]  | select(.id==$castid) | .character"))
		IFS="$OLDIFS"
		thumb=$(echo "${themoviedbshowepisodecredits}" | jq -r ".cast[]  | select(.id==$castid) | .profile_path")
		echo "	<actor>" >> "$nfo"
		echo "		<name>$name</name>" >> "$nfo"
		for role in ${!characters[@]}; do
			name="${characters[$role]}"
			echo "		<role>$name</role>" >> "$nfo"
		done
		echo "		<order>$order</order>" >> "$nfo"
		if [ ! "$thumb" == null ]; then
			echo "		<thumb>https://www.themoviedb.org/t/p/original${thumb}</thumb>" >> "$nfo"
		fi
		echo "		<tmdbid>$castid</tmdbid>" >> "$nfo"
		echo "	</actor>" >> "$nfo"
	done
	for id in ${!sonarrepisodeguestcast[@]}; do
		castid="${sonarrepisodeguestcast[$id]}"
		name="$(echo "${themoviedbshowepisodecredits}" | jq -r ".guest_stars[] | select(.id==$castid) | .name")"
		order=$(echo "${themoviedbshowepisodecredits}" | jq -r ".guest_stars[] | select(.id==$castid) | .order")
		OLDIFS="$IFS"
		IFS=$'\n'
		characters=($(echo "${themoviedbshowepisodecredits}" | jq -r ".guest_stars[]  | select(.id==$castid) | .character"))
		IFS="$OLDIFS"
		thumb=$(echo "${themoviedbshowepisodecredits}" | jq -r ".guest_stars[]  | select(.id==$castid) | .profile_path")
		echo "	<actor>" >> "$nfo"
		echo "		<name>$name</name>" >> "$nfo"
		for role in ${!characters[@]}; do
			name="${characters[$role]}"
			echo "		<role>$name</role>" >> "$nfo"
		done
		echo "		<order>$order</order>" >> "$nfo"
		if [ ! "$thumb" == null ]; then
			echo "		<thumb>https://www.themoviedb.org/t/p/original${thumb}</thumb>" >> "$nfo"
		fi
		echo "		<tmdbid>$castid</tmdbid>" >> "$nfo"
		echo "	</actor>" >> "$nfo"
	done
	echo "</episodedetails>" >> "$nfo"
	tidy -w 2000 -i -m -xml "$nfo" &>/dev/null
	log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Episode $episodeprocessid of $episodefileidscount :: $sonarrepisodetitle :: Writing Complete"
}

for id in ${!sonarrseriesids[@]}; do
	mainprocessid=$(( $id + 1 ))
	sonarr_series_id="${sonarrseriesids[$id]}"
	SeriesNFOWriter
	continue
	# Begin Processing Episodes
	for id in ${!episodefileids[@]}; do
		episodeprocessid=$(( $id + 1 ))
		sonarr_episodefile_id="${episodefileids[$id]}"
		EpisodeNFOWriter

	done
done

exit 0
