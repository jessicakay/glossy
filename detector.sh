#
#
# github.com/jessicakay/glossy
#
# jessdkant.bsky.social
#

printf "\n\t github.com/jessicakay/glossy\n"
read -p $'\n\t ~ Target (url): ' targ
read -p $'\t ~ choose filename prefix: ' outNAME

targ="${targ:=$default_URL}"
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
	printf "\n\t-> detected 1 stream type=m3u8\n ~ attempting download..."
	ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u" -oP | grep "https" -m 1) -c copy $outNAME.mp4
	exit 1
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
		ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u" -oP | grep "https" -m 1) -c copy $outNAME.mp4
	fi
else
	printf "\n\t-> no playlist found..."
fi

