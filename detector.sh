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

if [[ $detect_m3u8 == 1 ]]; then
	printf "\n\t-> detected 1 stream type=m3u8\n \n\t~ attempting download...\n"
	case "$file_fmt" in
		v) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" | uniq ) -c copy $outNAME.mp4 ; return ;;
		a) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" | uniq ) -vn -ac 2 -b:a 192k $outNAME.mp3 ; return ;;
		b) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" | uniq ) -c copy $outNAME.mp4 &&
			ffmpeg -i $outNAME.mp4 -c:a -acodec libmp3lame -vn $outname.mp3
			return ;;
	esac
elif [[ $detect_m3u8 > 1 ]]; then
	printf "\n\t-> detected $detect_m3u8 m3u8 streams\n\t"
	read -p " ~ enumerate [y/n]?: " enum_streams
	if [[ $enum_streams == "y" ]]; then
		printf "\n" && echo $buffer |  tr "\"" "\n" > counter_temp
		cat counter_temp | tr "\"" "\n" | grep -P "https.*?[^\":]\....?.$" | \
		grep -Po "\.[pm]..?[^\/]$" | sort | uniq -c
		printf "\n"
	fi
	read -p $'\t ~ multiple streams located, use -m 1 [y/n]?' m_one
	printf "\n\n"
	if [[ $m_one == "y" ]]; then
		case "$file_fmt" in
			v) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" -m 1) -c copy $outNAME.mp4 ; return ;;
			a) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" -m 1) -vn -ac 2 -b:a 192k $outNAME.mp3 ; return ;;
			b) ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" -m 1) -c copy $outNAME.mp4 &&
				ffmpeg -i $outNAME.mp4 -vn -ac 2 -b:a 192k $outname.mp3
				return ;;
		esac
		ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u?8" -oP | grep "https" -m 1) -c copy $outNAME.mp4
	fi
else
	printf "\n\t-> no playlist found..."
fi

