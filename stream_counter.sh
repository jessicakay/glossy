#
# stream counter based on RI capital TV
#
# github.com/jessicakay/glossy
#
# jessdkant.bsky.social
#

# page lists all media content in JSON in source
default_URL="capitoltvri.cablecast.tv/watch/stream/1"
if ! [[ -v targ &&  "${#targ}" -gt 0 ]]; then
	targ=$default_URL
	printf "\n\t"; else printf "\n\t $(echo "[ current  URL: "  $targ "]") \n\t" ;
fi
read -p " -> Target (url): " targ
targ="${targ:=$default_URL}"
curl $targ |  tr "\"" "\n" > counter_temp
	sed 's/,/\n/g' counter_temp | grep '^https.*?m3u?8$' -E | \
	printf "\n\tThere are $(wc -l) m3u/m3u8 streams\n" &&
	grep -P "http" counter_temp |
		printf "\t$(grep "mp4$" -c) mp4 files found\n" &&
		printf "\t$(grep -Ec '.pdf$' counter_temp) pdf files found.\n\n\tlivestreams:\n\n" &&
		sed  's/\\//g' counter_temp | grep "http.*live?stream=[0-9+]" -o |
			sort | uniq | printf "$(grep -Po "(?s)https:/\/\\K.*" |
			sed 's/^/\t-> /g')\n\n"
