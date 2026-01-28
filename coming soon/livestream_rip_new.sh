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

# direct MP4 link
if [[ "$targ" =~ \.mp4($|\?) ]]; then
    targURL="$targ"
# direct M3U8 link
elif [[ "$targ" =~ \.m3u8($|\?) ]]; then
    targURL="$targ"
# otherwise poll url for m3u8
else
    targURL=$(curl -Ls "$targ" | tr "'" "\n" |
              grep -oP 'https?://[^"]+\.m3u?8' | head -n 1)
fi

if [[ -z "$targURL" ]]; then
    echo "unable to resolve URL $targ"
    exit 1
fi

ffmpeg -i "$targURL" -c copy \
    -segment_time "$timestamp" \
    -reset_timestamps 1 \
    -segment_list_flags +live \
    -segment_list "$outNAME.m3u8" \
    -f segment "$outNAME%03d.mp4" &  # & to background this and run whisper in parallel!
ffpid=$!  # capture PID to track/kill

# wait to quit on ctrl+c until whipser is done
trap 'kill "$ffpid" 2>/dev/null' INT
# uncomment to exit immediately
# trap 'kill "$ffpid" 2>/dev/null; exit 1' INT

processed_segments=()
final_pass_needed=0  # loop variable so we break 1 loop after ffmpeg dies
while true; do  # loop while ffmpeg is running

    # If playlist exists, process segments
    if [[ -f "$outNAME.m3u8" ]]; then
        # read segment names from ffmpeg playlist
        segs=$(grep -oE "${outNAME}[0-9]+\.mp4" "$outNAME.m3u8" 2>/dev/null)

        for f in $segs; do
            # Skip if already processed
            if printf '%s\n' "${processed_segments[@]}" | grep -qx "$f"; then
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
    fi

    # Check if ffmpeg is still alive
    if ! kill -0 "$ffpid" 2>/dev/null; then
        # FFmpeg is dead — request one more loop
        if (( final_pass_needed == 0 )); then
            final_pass_needed=1
        else
            # We already did the final pass
            break
        fi
    fi

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

