#
#
# github.com/jessicakay/glossy
#
# jessdkant.bsky.social
#


printf "\n\t github.com/jessicakay/glossy\n"
read -p $'\n\t ~ Target (url): ' targ
read -p $'\n\t ~ choose filename prefix: ' outNAME
targ="${targ:=$default_URL}"

read -p $'\t ~ [a]udio [v]ideo or [b]oth: ' file_fmt
case "$file_fmt" in
	a) file_form="mp3" ;;
	v) file_form="mp4" ;;
	b) file_form="mp4" ;;
	*)
		printf "\n\t-! incorrect format choice, exiting...\n"
		return ;;
esac

buffer="$(curl -s $targ)"
detect_m3u8="$(echo $buffer | sed 's/\"/\n/g' | grep  -Po "http.*m3u8" | uniq | wc -l)"

function file_enumerater (){
	read -p $'\n\t ~ enumerate [y/n]?: ' enum_streams
	if [[ $enum_streams == "y" ]]; then
		printf "\n" && echo $buffer |  tr "\"" "\n" > counter_temp
		cat counter_temp | tr "\"" "\n" | grep -P "https.*?[^\":]\....?.$" | \
		grep -Po "\.[pm]..?[^\/]$" | sort | uniq -c
		printf "\n"
	fi
	}

function grab_menu() {
	case "$file_fmt" in
		v) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" -m 1) -c copy $outNAME.mp4 ; return ;;
		a) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" -m 1) -vn -ac 2 -b:a 192k $outNAME.mp3 ; return ;;
		b) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" -m 1) -c copy $outNAME.mp4 &&
			ffmpeg -i $outNAME.mp4 -vn -ac 2 -b:a 192k $outname.mp3
			return ;;
	esac
	}

function grab_inv(){
	if ! [[ -z $(  curl -s $new_targ ) ]]; then
		case "$file_fmt" in
			a) targ=$new_targ ; ffmpeg -i $targ -vn -ac 2 -b:a 192k $outNAME.mp3 ;;
			v) targ=$new_targ ; ffmpeg -i $targ -c copy $outNAME.mp4 ;;
			b) targ=$new_targ ; ffmpeg -i $targ -c copy $outNAME.mp4 &&
				ffmpeg -i $outNAME.mp4 --vn -ac 2 -b:a 192k $outNAME.mp3 ;;
		esac
		fi
		}

unset platform_type

if ! [[ -z $( echo $targ | grep "sliq" ) ]];
	then printf "\n\t-> Sliq platform detected"
	platform_type="sliq"
elif ! [[ -z $( echo $buffer | grep -i "invintus" ) ]]; then
	printf "\n\t-> Invintus platform detected"
	platform_type="invs"
elif ! [[ -z $( echo $targ | grep "granicus") ]] || ! [[ -z $( echo $buffer | grep "granicus")  ]]; then
	printf "\n\t-> Granicus platform detected"
	platform_type="gran"
else
	printf "\n\t-! platform not detected, searching for streams..."
fi

if  [[ -n $( echo $buffer | grep "\Khttps.*?m3u?8" -oP | grep "https" | uniq ) ]]; then
	if [[ $detect_m3u8 == 1 ]]; then
		printf "\n\t-> detected 1 stream type=m3u8\n \n\t~ attempting download...\n"
		 if [[ $(echo $targ | grep "live" -c ) > 0 ]] || [[ $(echo $buffer | grep "live" -Po -c ) > 0 ]]; then
			printf "\n\t-> potentially live, launch livestream ripper? "
			read -p "[y/n]: " launch_live
			case "$launch_live" in
				y) source livestream_rip.sh ; return;;
				*) printf "\n\t ~ not launching, continuing detection...";;
			esac
		 fi
			case "$file_fmt" in
				v) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" | uniq ) -c copy $outNAME.mp4 ; return ;;
				a) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" | uniq ) -vn -ac 2 -b:a 192k $outNAME.mp3 ; return ;;
				b) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" | uniq ) -c copy $outNAME.mp4 &&
					ffmpeg -i $outNAME.mp4 -vn -ac 2 -b:a 192k $outNAME.mp3
					return ;;
			esac
	else
		printf "\n\t-! stream not found... \n";
		file_enumerater
#		return;
	fi
elif [[ $detect_m3u8 > 1 ]]; then
	printf "\n\t-> detected $detect_m3u8 m3u8 streams\n\t"
	file_enumerater
	read -p $'\t ~ multiple streams located, use -m 1 [y/n]?' m_one
	printf "\n\n"
	if [[ $m_one == "y" ]]; then
		grab_menu
		ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" -m 1) -c copy $outNAME.mp4
	fi
else
	printf "\n\t-> no playlist found...\n"

	if [[ platform_type == "invs" ]]; then
		printf "\n\t ~ grabbing identifiers...\n\n"
		curl -s -m 10 --no-keepalive $targ > temp.txt
		if ! [[ -z $(echo $targ | grep -Pozi "ClientID="| tr -d '\0' ) ]] && ! [[ -z $(echo $targ | grep -Pozi "eventID=" | tr -d '\0' ) ]]; then
			clientid="$(echo $targ | grep -Pozi "ClientID=\K[0-9]+" | tr -d '\0' )"
			event_id="$(echo $targ | grep -Pozi "eventID=\K[0-9]+" | tr -d '\0' )"
			printf "\n\t ~ client ID $clientid\n\t ~ event ID $event_id\n\n\t ~ attempting to grab stream..\n\n"
			new_targ="https://api.v3.invintus.com/StreamURI/hls/$clientid/$event_id/media.m3u8"
			printf "\n$new_targ\n"
			grab_inv
		elif ! [[ -z $(echo $buffer| grep -Pozi "ClientID=" ) ]] &&  [[ -z $(echo $targ | grep -Pozi "eventID=" | tr -d '\0' ) ]]; then
			clientid="$(cat temp.txt | tr "\'" " " | grep -Pozi "ClientID\K.*?[0-9]+" | tr -d '\0' )"
			event_id="$(cat temp.txt | tr "\'" " " | grep -Pozi "eventID.*?\K[0-9]+[^\{\}]" -m 1 | tr -d '\0' )"
			printf "\n\t\t ~ client ID $clientid\n\t\t ~ event ID $event_id\n"
			rm temp.txt
		else
			# some implementations use redirects, no-keepalive overrides throttling
			curl -s -m 10 --no-keepalive -L $targ > temp.txt
			clientid="$(cat temp.txt | tr "\'" " " | grep -Pozi "ClientID.*?\K[0-9:]+" -m 1 |  tr -d '\0:' )"
			event_id="$(cat temp.txt | tr "\'" " " | grep -Pozi "event.*?\K[0-9:]+" -m 1 |  tr -d '\0' |
				sed 's/:/\n/g' | grep "[0-9]+" -oP | uniq )"
			printf "\n\t ~ client ID $clientid\n\t ~ event ID $event_id\n"
			new_targ="https://api.v3.invintus.com/StreamURI/hls/$clientid/$event_id/media.m3u8"
			printf "\n$new_targ\n"
			grab_inv
		fi
	fi
	if [[ $(echo $buffer | grep "SSL certificate problem" -Po)==TRUE  ]]; then
				printf "\n\t-! SSL certificate problem detected\n"
				if ! [[ -z $(curl -sL $targ --insecure | tr "\"" "\n" | grep -P "https.*?\.[a-z]..?[^/]$" ) ]]; then
					# add selenium/phantomjs later to harvest file locations loaded by javascript handlers
					printf "\n\t ~ try javascript?\n"
				fi
	else
		case "$platform_type" in
			sliq | gran | invs) printf "\n\t-! error: $platform_type\n"
				if ! [[ -z $(curl -s $targ | grep "\Khttps.*?mp4" -oPm 1) ]]; then
					printf "\n\t-> direct mp4 download found"
					ffmpeg -i $(curl -s $targ | grep "\Khttps.*?mp4" -oPm 1) -c copy $outNAME.mp4
				else
					printf "\n\t-! $platform_type detected, but no media files found\n\n\t ~ exiting... \n\n"
					return
				fi;;
			*)
				if ! [[ -z $(curl -s $targ | grep "\Khttps.*?mp4" -oPm 1) ]]; then
					printf "\n\t-> direct mp4 download found"
					ffmpeg -i $(curl -s $targ | grep "\Khttps.*?mp4" -oPm 1) -c copy $outNAME.mp4
				else
					printf "\n\t-! likely self-hosted but no media files found\n\n\t ~ exiting... \n\n"
				fi;;
		esac


	fi
fi
