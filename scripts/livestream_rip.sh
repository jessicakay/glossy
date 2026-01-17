#
# livestream ripper
# part of the github.com/jessicakay/glossy repo
#
# https://jessk.org/blog/streamripping-democracy
# jessdkant.bsky.social
#

# version 1
#
# read -p "Target (url): " targ
# read -p "choose filename prefix: " outNAME
# targURL=$(curl -L $targ | tr "\'" "\n" |
#	grep "\Khttp.*?media.*?m3u?8" -Poz | tr -d '\0') &&
#	ffmpeg -i $targURL -c copy -segment_time 00:20:00 -f # -reset_timestamps 1 \
#	segment $outNAME%03d.mp4

# version 2
#
# read -p "Target (url): " targ
# read -p "choose filename prefix: " outNAME
# read -p "save every (in mins): " segSIZE
# printf -v hourmins "%02d:%02d" "$((segSIZE / 60))" "$((segSIZE % 60))"
# timestamp="$hourmins:00"
# targURL=$(curl -L $targ | tr "\'" "\n" |
# 	grep "\Khttp.*?media.*?m3u?8" -Poz | tr -d '\0') &&
# 	ffmpeg -i $targURL -c copy -segment_time $timestamp \
# 	-reset_timestamps 1 \
#     -segment_list $outNAME.m3u8	\
# 	-f segment $outNAME%03d.mp4
#
# uncomment to add WhisperX LLM transcription:
#
# watch -g -n 1 --no-title grep -oE 'outNAME[0-9]+.mp4' $outNAME.m3u8 &&
# tail -n 1 $outNAME.m3u8 |
#   whisper --language English --model base.en --verbose True \
#   --task transcribe --output_format txt
#
#if (( $(ls act* | wc -l) > 1 )); then
#    read -p "delete last segment? [y/n]: " opt
#    if [[ $opt == "y" ]]; then
#        # clean up: since break is partial, remove last segment
#        rm $(ls $outNAME* | sort | tail -n 1);
#    fi
#    # merge segments into single file and create audio-only file for easy transcription
#    echo $(ls $outNAME*) | sed 's/ /\n/g' |  sed 's/^/file /g' > temp
#    ffmpeg -f concat -i temp -c copy "${outNAME}_all.mp4" && rm temp
#    ffmpeg -i "${outNAME}_all.mp4" -vn -ac 2 -b:a 192k "${outNAME}_all.mp3";
#fi

# version 3

read -p "Target (url): " targ
read -p "choose filename prefix: " outNAME
read -p "save every (in mins): " segSIZE
printf -v hourmins "%02d:%02d" "$((segSIZE / 60))" "$((segSIZE % 60))"
timestamp="$hourmins:00"
targURL=$(curl -L "$targ" | tr "\'" "\n" |
          grep "\Khttp.*?media.*?m3u?8" -Poz | tr -d '\0')
if [[ -z "$targURL" ]]; then
    echo "unable to resolve URL $targ"
    exit 1
fi

ffmpeg -i "$targURL" -c copy \
    -segment_time "$timestamp" \
    -reset_timestamps 1 \
    -segment_list "$outNAME.m3u8" \
    -f segment "$outNAME%03d.mp4" &  # & to background this and run whisper in parallel!
ffpid=$!  # capture PID to track/kill

trap 'kill "$ffpid" 2>/dev/null; exit 1' INT

processed_segments=()
while kill -0 "$ffpid" 2>/dev/null; do  # loop while ffmpeg is running
    for f in ${outNAME}*.mp4; do
        # Skip if already processed
        if printf '%s\n' "${processed_segments[@]}" | grep -qx "$f"; then
            continue
        fi

        # Skip if file is still being written
        if lsof "$f" >/dev/null 2>&1; then
            continue
        fi

        # uncomment to add WhisperX LLM transcription:
        whisper "$f" \
            --language English \
            --model base.en \
            --verbose True \
            --task transcribe \
            --output_format txt

        processed_segments+=("$f")
    done
    sleep 1 # loop while ffmpeg is running
done

if (( $(ls ${outNAME}*.mp4 | wc -l) > 1 )); then
    read -p "delete last segment? [y/n]: " opt
    if [[ $opt == "y" ]]; then
        # clean up: since break is partial, remove last segment
        rm $(ls "$outNAME"*.mp4 | sort | tail -n 1);
    fi
    # merge segments into single file and create audio-only file for easy transcription
    ls "${outNAME}"*.mp4 | sort | sed 's/^/file /' > temp
    ffmpeg -f concat -i temp -c copy "${outNAME}_all.mp4" && rm temp
    ffmpeg -i "${outNAME}_all.mp4" -vn -ac 2 -b:a 192k "${outNAME}_all.mp3";
fi

