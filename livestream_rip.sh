
# rips AZleg livestream in real-time, storing output in 20 minute chunks
# version 1

read -p "Target (url): " targ
read -p "choose filename prefix: " outNAME
targURL=$(curl -L $targ | tr "\'" "\n" |
	grep "\Khttp.*?media.*?m3u?8" -Poz | tr -d '\0') &&
	ffmpeg -i $targURL -c copy -segment_time 00:20:00 -f -reset_timestamps 1 \
	segment $outNAME%03d.mp4

# version 2
read -p "Target (url): " targ
read -p "choose filename prefix: " outNAME
read -p "save every (in mins): " segSIZE
printf -v hourmins "%02d:%02d" "$((segSIZE / 60))" "$((segSIZE % 60))"
timestamp="$hourmins:00"
targURL=$(curl -L $targ | tr "\'" "\n" |
	grep "\Khttp.*?media.*?m3u?8" -Poz | tr -d '\0') &&
	ffmpeg -i $targURL -c copy -segment_time $timestamp -reset_timestamps 1 \
	-f segment $outNAME%03d.mp4

# clean up: since break is partial, remove last segment
rm $(ls $outNAME* | sort | tail -n 1)

# merge segments into single file and create audio-only file for easy transcription
echo $(ls $outNAME*) | sed 's/ /\n/g' |  sed 's/^/file /g' > temp &&
ffmpeg -f concat -i temp -c copy "${outNAME}_all.mp4" && rm temp &&
ffmpeg -i "${outNAME}_all.mp4" -vn -ac 2 -b:a 192k "${outNAME}_all.mp3"

