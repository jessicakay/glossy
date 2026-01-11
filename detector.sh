#
#
# github.com/jessicakay/glossy
#
# jessdkant.bsky.social
#


read -p " -> Target (url): " targ
targ="${targ:=$default_URL}"
buffer="$(curl $targ)"
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
	printf "\n\t-> detected 1 stream type=m3u8\n"
	platform_type="rawm"
elif [[ $detect_m3u8 > 1 ]]; then
	printf "\n\t-> detected $detect_m3u8 m3u8 streams\n\t ~ enumering files: \n\n"
	echo $buffer |  tr "\"" "\n" > counter_temp
	cat counter_temp | tr "\"" "\n" | grep -P "https.*?[^\":]\....?.$" | \
	grep -Po "\....?.$" | sort | uniq -c && echo -e "\n"
else
	printf "\n\t-> no playlist found..."
fi

