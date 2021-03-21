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
for id in ${!sonarrseriesids[@]}; do
	mainprocessid=$(( $id + 1 ))
	sonarr_series_id="${sonarrseriesids[$id]}"
	sonarrseriesepisodes="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episode?seriesId=$sonarr_series_id")"
	episodefileidscount=$(echo "$sonarrseriesepisodes" | jq -r ".[] | select(.hasFile=="true") | .episodeFileId" | wc -l)
	episodefileids=($(echo "$sonarrseriesepisodes" | jq -r ".[] | select(.hasFile=="true") | .episodeFileId"))
	for id in ${!episodefileids[@]}; do
		episodeprocessid=$(( $id + 1 ))
		sonarr_episodefile_id="${episodefileids[$id]}"	
		sonarrseriesid="$sonarr_series_id"
		sonarrepisodefileid="$sonarr_episodefile_id"
		sonarrseriesdata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/series/$sonarrseriesid")"
		sonarrepisodedata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episode?seriesId=$sonarrseriesid" | jq -r ".[] | select(.episodeFileId==$sonarrepisodefileid)")"
		sonarrepisodefiledata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$SonarrUrl/api/v3/episodefile/$sonarrepisodefileid")"
		sonarrepisodetvdbId="$(echo "$sonarrseriesdata" | jq -r ".tvdbId")"
		sonarrepisodeseasonnumber="$(echo "$sonarrepisodedata" | jq -r ".seasonNumber")"
		sonarrepisodenumber="$(echo "$sonarrepisodedata" | jq -r ".episodeNumber")"
		themoviedbid=$(curl -s "https://api.themoviedb.org/3/find/$sonarrepisodetvdbId?api_key=$themoviedbapikey&external_source=tvdb_id" | jq -r ".tv_results[].id")
		themoviedbshowdata=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid?api_key=$themoviedbapikey" | jq -r ".")
		themoviedbshowvideos=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/videos?api_key=$themoviedbapikey" | jq -r ".")
		themoviedbshowcredits=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/aggregate_credits?api_key=$themoviedbapikey" | jq -r ".")
		themoviedbshowseasondata=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/season/${sonarrepisodeseasonnumber}?api_key=$themoviedbapikey" | jq -r ".")
		themoviedbshowseasonvideos=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/season/${sonarrepisodeseasonnumber}/videos?api_key=$themoviedbapikey" | jq -r ".")
		themoviedbshowepisodedata=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid/season/${sonarrepisodeseasonnumber}/episode/${sonarrepisodenumber}?api_key=$themoviedbapikey" | jq -r ".")
		themoviedbshowepisodecredits=$(curl -s "https://api.themoviedb.org/3/tv/$themoviedbid//season/${sonarrepisodeseasonnumber}/episode/${sonarrepisodenumber}/credits?api_key=$themoviedbapikey" | jq -r ".")

		sonarrepisodetitle="$(echo "${sonarrepisodedata}" | jq -r ".title")"
		sonarrepisodeoverview="$(echo "$sonarrepisodedata" | jq -r ".overview")"
		sonarrepisodeairdate="$(echo "$sonarrepisodedata" | jq -r ".airDate")"
		sonarrseriestitle="$(echo "$sonarrseriesdata" | jq -r ".title")"
		sonarrepisodefile="$(echo "$sonarrepisodefiledata" | jq -r ".path")"
		sonarrepisoderuntime="$(echo "$sonarrepisodefiledata" | jq -r ".mediaInfo.runTime")"
		sonarrepisoderuntime=${sonarrepisoderuntime:0:2}
		sonarrepisodefolderpath="$(dirname "$sonarrepisodefile")"
		sonarrepisodefilename="$(basename "$sonarrepisodefile")"
		sonarrepisodefilenamenoext="${sonarrepisodefilename%.*}"
		sonarrepisodefilenamethumb="${sonarrepisodefile%.*}-thumb.jpg"
		sonarrshowpath="$(echo "$sonarrseriesdata" | jq -r ".path")"
		sonarrshowtitle="$(echo "$sonarrseriesdata" | jq -r ".title")"
		sonarrshowsorttitle="$(echo "$sonarrseriesdata" | jq -r ".sortTitle")"
		sonarrshowmpaa="$(echo "$sonarrseriesdata" | jq -r ".certification")"
		sonarrshowoverview="$(echo "$sonarrseriesdata" | jq -r ".overview")"
		sonarrshowimdbid="$(echo "$sonarrseriesdata" | jq -r ".imdbId")"
		sonarrshowyear="$(echo "$sonarrseriesdata" | jq -r ".year")"
		sonarrshownetwork="$(echo "$sonarrseriesdata" | jq -r ".network")"
		sonarrseriespremiered="$(echo "${themoviedbshowdata}" | jq -r ".first_air_date")"
		sonarrseriesstatus="$(echo "${themoviedbshowdata}" | jq -r ".status")"
		sonarrshowlocalposter="MediaCover/${sonarrseriesid}/poster.jpg"
		sonarrshowposter=$(echo "${sonarrseriesdata}" | jq -r ".images[] | select(.coverType==\"poster\") | .remoteUrl")
		sonarrshowlocalfanart="MediaCover/${sonarrseriesid}/fanart.jpg"
		sonarrshowfanart=$(echo "${sonarrseriesdata}" | jq -r ".images[] | select(.coverType==\"fanart\") | .remoteUrl")
		sonarrshowlocalbanner="MediaCover/${sonarrseriesid}/banner.jpg"
		sonarrshowbanner=$(echo "${sonarrseriesdata}" | jq -r ".images[] | select(.coverType==\"banner\") | .remoteUrl")
		poster="$sonarrshowpath/poster.jpg"
		fanart="$sonarrshowpath/fanart.jpg"
		banner="$sonarrshowpath/banner.jpg"
		sonarrseriestagline="$(echo "${themoviedbshowdata}" | jq -r ".tagline")"
		OLDIFS="$IFS"
		IFS=$'\n'
		sonarrseriesgenres=($(echo "${themoviedbshowdata}" | jq -r ".genres[] | .name"))
		sonarrepisodedirectors=($(echo "${themoviedbshowepisodecredits}" | jq -r ".crew[] | select(.job==\"Director\") | .name"))
		sonarrepisodewriters=($(echo "${themoviedbshowepisodecredits}" | jq -r ".crew[] | select(.job==\"Writer\") | .name"))
		IFS="$OLDIFS"
		sonarrshowcast=($(echo "${themoviedbshowcredits}" | jq -r ".cast[] | .id"))
		sonarrshowseasons=($(echo "${themoviedbshowdata}" | jq -r ".seasons[] | .id"))
		sonarrepisodecast=($(echo "${themoviedbshowepisodecredits}" | jq -r ".cast[] | .id"))
		sonarrepisodeguestcast=($(echo "${themoviedbshowepisodecredits}" | jq -r ".guest_stars[] | .id"))
		sonarrepisodeid=$(echo "${themoviedbshowepisodedata}" | jq -r ".id")
		sonarrepisodethumb=$(echo "${themoviedbshowepisodedata}" | jq -r ".still_path")

		nfo="$sonarrshowpath/tvshow.nfo"

		log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle"
		if cat "$nfo" | grep "tmdb" | read; then
			sleep 0.01
		else
			touch -d "2 hours ago" "$nfo" 
		fi

		if find "$nfo" -name "tvshow.nfo" -type f -mtime +30 | read; then
			log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Show :: NFO detected, removing..."
			rm "$nfo"
		else
			log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Show :: Detected NFO doesn't require update..." 
		fi

		if [ ! -f "$nfo" ]; then
			log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Show :: Writing NFO..."

			echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" >> "$nfo"
			echo "<tvshow>" >> "$nfo"
			echo "    <title>$sonarrshowtitle</title>" >> "$nfo"
			echo "    <sorttitle>$sonarrshowsorttitle</sorttitle>" >> "$nfo"
			echo "    <plot>$sonarrshowoverview</plot>" >> "$nfo"
			echo "    <tagline>$sonarrseriestagline</tagline>" >> "$nfo"
			echo "    <userrating></userrating>" >> "$nfo"
			if [ -f "/config/${sonarrshowlocalposter}" ]; then
				if [ ! -f "$poster" ]; then
					cp "/config/${sonarrshowlocalposter}" "$poster"
				fi
			fi
			if [ -f "/config/${sonarrshowlocalfanart}" ]; then
				if [ ! -f "$fanart" ]; then
					cp "/config/${sonarrshowlocalfanart}" "$fanart"
				fi
			fi
			if [ -f "/config/${sonarrshowlocalbanner}" ]; then
				if [ ! -f "$banner" ]; then
					cp "/config/${sonarrshowlocalbanner}" "$fanart"
				fi
			fi
			if [ -f "$poster" ]; then
				echo "	<thumb aspect=\"poster\">poster.jpg</thumb>" >> "$nfo"
			else
				echo "	<thumb aspect=\"poster\">$sonarrshowposter</thumb>" >> "$nfo"
			fi
			if [ -f "$banner" ]; then
				echo "	<thumb aspect=\"banner\">banner.jpg</thumb>" >> "$nfo"
			else
				echo "	<thumb aspect=\"banner\">$sonarrshowbanner</thumb>" >> "$nfo"
			fi
			echo "	<fanart>" >> "$nfo"
			if [ -f "$fanart" ]; then
				echo "	    <thumb>fanart.jpg</thumb>" >> "$nfo"
			else
				echo "	    <thumb>$sonarrshowfanart</thumb>" >> "$nfo"
			fi
			echo "    <mpaa>$sonarrshowmpaa</mpaa>" >> "$nfo"
			echo "    <uniqueid type=\"tvdb\" default=\"true\">$sonarrepisodetvdbId</uniqueid>" >> "$nfo"
			echo "    <uniqueid type=\"tmdb\">$themoviedbid</uniqueid>" >> "$nfo"
			echo "    <uniqueid type=\"imdb\">$sonarrshowimdbid</uniqueid>" >> "$nfo"
			for genre in ${!sonarrseriesgenres[@]}; do
				seriesgenre="${sonarrseriesgenres[$genre]}"
				echo "	<genre>$seriesgenre</genre>" >> "$nfo"
			done
			echo "    <premiered>$sonarrseriespremiered</premiered>" >> "$nfo"
			echo "    <year>$sonarrshowyear</year>" >> "$nfo"
			echo "    <status>$sonarrseriesstatus</status>" >> "$nfo"
			echo "    <studio>$sonarrshownetwork</studio>" >> "$nfo"
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
				fi
				echo "		<tmdbid>$castid</tmdbid>" >> "$nfo"
				echo "	</actor>" >> "$nfo"
			done
			for id in ${!sonarrshowseasons[@]}; do
				seasonid="${sonarrshowseasons[$id]}"
				seasonname="$(echo "${themoviedbshowdata}" | jq -r ".seasons[] | select(.id==$seasonid) | .name")"
				seasonnumbere="$(echo "${themoviedbshowdata}" | jq -r ".seasons[] | select(.id==$seasonid) | .season_number")"
				echo "    <namedseason number=\"$seasonnumbere\">$seasonname</namedseason>" >> "$nfo"
			done
			echo "</tvshow>" >> "$nfo"

			if [ -f "$nfo" ]; then
				log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Show :: Writing Complete"
			fi
		fi

		nfo="${sonarrepisodefolderpath}/${sonarrepisodefilenamenoext}.nfo"
		if [ -f "$nfo" ]; then
			rm "$nfo"
		fi
		log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Episode $episodeprocessid of $episodefileidscount :: $sonarrepisodetitle :: Writing NFO..."
		echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" >> "$nfo"
		echo "<episodedetails>" >> "$nfo"
		echo "    <title>$sonarrepisodetitle</title>" >> "$nfo"
		echo "    <showtitle>$sonarrshowtitle</showtitle>" >> "$nfo"
		echo "    <userrating></userrating>" >> "$nfo"
		echo "    <season>$sonarrepisodeseasonnumber</season>" >> "$nfo"
		echo "    <episode>$sonarrepisodenumber</episode>" >> "$nfo"
		echo "    <plot>$sonarrepisodeoverview</plot>" >> "$nfo"
		echo "    <runtime>$sonarrepisoderuntime</runtime>" >> "$nfo"
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
		log "$mainprocessid of $sonarrseriesidscount :: Processing :: $sonarrseriestitle :: Episode $episodeprocessid of $episodefileidscount :: $sonarrepisodetitle :: Writing Complete"

	done
done


exit 0
