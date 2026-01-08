#
# part of the glossy transparency repo
# github.com/jessicakay/glossy
#
# jessdkant.bsky.social
#

# install packages

sudo apt install ffmpeg jq xclip

# find location of MP4 file on page
read -p "Target (url): " targ && ffmpeg -i $(curl -s $targ | grep "\Khttps.*?mp4" -oPm 1) -c copy outfile.mp4 

# find stream and rip to ffmpeg 
read -p "Target (url): " targ && ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u" -oP | grep "https" -m 1) -c copy outfile.mp4

# granicus
read -p "Target (url): " targ && ffmpeg -i $(curl $targ -L |
	tr "\'" "\n" |  grep "\Khttp.*?m3u?8" -Poz |
	grep "m3u" -z -m 1) -c copy out.mp4

# pull whole data model from Sliq, only show first 100 characters
grep '(?s)dataModel = \{.*?\};' outfile_temp -Poz | tail +2 | head -c 100

# extract transcript from embedded VTT subtitles file 
curl $(targ) | grep -i '[a-z]' | sed  's/\r//g' | tr '\n' ' '

# make shortcut to allow any user to expand subtitles of file with URL in clipboard
alias expvtt="curl $(xclip -selection clipboard -o) | grep -i '[a-z]' | sed  's/\r//g' | tr '\n' ' '"

# extract subtitles, concatenate into and search transcript for keywords:
# for Sliq platform

# simple version
read -p "Target (url): " targ && read -p "Keyword: " kw &&
    printf "\n\n" && curl $targ -o outfile_temp &&
	printf "\n results: \n\n" &&
	grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz |
	jq -c '.en[] | {Begin,Content} ' | tr "{|}" "\ " | tr ",|\"" " " |
	grep -i $kw && printf "\n"



# extract transcript from Sliq
# version 1
grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz | 
	jq |  tr "{|}'" "\n" | sed 's/^,$//g'| grep $kw | printf "\n\n"

# version 2
grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz |
	jq -c '.en[] | {Begin,Content} ' | tr "{|}" "\ " | tr ",|\"" " "

# version 3
grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz |  jq '.en | select(.Content | contains("$kw")) | {Begin, Content}'

# testing azleg.gov/actvlive
curl azleg.gov/actvlive | tr "\'" "\n" |  grep "\Khttp.*?media.*?m3u?8" -Poz

# rips AZleg livestream in real-time, storing output in 20 minute chunks

read -p "Target (url): " targ &&
read -p "choose filename prefix: " outNAME &&
targURL=$(curl -L $targ | tr "\'" "\n" |
	grep "\Khttp.*?media.*?m3u?8" -Poz | tr -d '\0') &&
	ffmpeg -i $targURL -c copy -segment_time 00:20:00 -f -reset_timestamps 1 \
	segment $outNAME%03d.mp4

# merge segments into single file and create audio-only file for easy transcription
echo $(ls $outNAME*) | sed 's/ /\n/g' |  sed 's/^/file /g' > temp && 
ffmpeg -f concat -i temp -c copy "${outNAME}_all.mp4" && rm temp &&
ffmpeg -i "${outNAME}_all.mp4" -vn -ac 2 -b:a 192k "${outNAME}_all.mp3"

# for rhode island
# RI Capital TV loads *all* media files into source
# see: stream_counter.sh for full script
curl $targ |  tr "\"" "\n" | grep  "\Khttps.*?1080.*?m3u?8" -Poz -m 1

