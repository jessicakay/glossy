# generate list of subtitle files in California archive


if [ -f vtt_index ]; then
	printf "\n\t-> index file located.\n\t-> $(wc -l vtt_index ) entries in index\n\n"
else
	printf "\n\t -! index not found. building...\n\n"
	targ="https://www.senate.ca.gov/media-archive?page="
	read -p $'\n\t -> how many pages should I parse? ' parse_depth ; printf "\n"
	i=1
	while (( $i < $parse_depth+1 ))
	do
		curl -q $targ$i | tr '\"' '\n' | grep "http?s:\/\/.*?vtt" -Po >> vtt_index
		printf "\n\t parsing $targ$i,,,\n"
		let i++
	done
	printf "\n\t-> $(wc -l vtt_index ) vtt files located.\n\n"
fi

read -p $'\n\t-> year to search? ' year
printf "\n\t-> $(grep -c $year vtt_index ) files located\n\n"

mkdir $year && cd $year
grep $year ../vtt_index > temp

secs_floor=$(grep $year temp -c )
secs_max=$(($(grep $year temp -c ) * 10))
mins_floor=$(($secs_floor / 60))
mins_max=$(($secs_max / 60))

printf "\n\t ~ total download time: approx. $mins_floor - $mins_max minutes\n\n"

cd ..
rm -r $year

# wget -q --show-progress -i temp --wait=10 --random-wait
# rm temp
