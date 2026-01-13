# glossy

### tips from [jessk.org/blog/streamripping-democracy](https://https://jessk.org/blog/streamripping-democracy)

## install packages

* code snippets are written in bash. You can either use them natively in linux (tested on ubuntu), or download Cygwin or Linux Subsystem for Linux (WSL). The syntax will be different for bash commands but once pacakges are installed, the rest of this should work on any linux shell wth minimal tweaking.

    for apt package manager:

        sudo apt install ffmpeg jq xclip

### basic scripts for downloading files

* the majority of the rest of the repo are extra features wrapped around these simple comands. Copy them and paste into a text editor or directly into the terminal

    find mp4 on page, copy from ffmpeg

        read -p "Target (url): " targ && ffmpeg -i $(curl -s $targ |
        grep "\Khttps.*?mp4" -oPm 1) -c copy outfile.mp4

    find stream and rip to ffmpeg

        read -p "Target (url): " targ && ffmpeg -i $(curl $targ | \
        grep "\Khttps.*?m3u" -oP | grep "https" -m 1) -c copy outfile.mp4

     granicus platform specific

        read -p "Target (url): " targ && ffmpeg -i $(curl $targ -L |
        tr "\'" "\n" |  grep "\Khttp.*?m3u?8" -Poz |
        grep "m3u" -z -m 1) -c copy out.mp4


### working with Sliq pages

* these features are snippets of code for working wth Sliq, specifically around parsing subtitles and converting them to transcripts

    pull whole data model from Sliq, only show first 100 characters

        curl $targ -L |	tr "\'" "\n" > outfile_temp &&
        grep '(?s)dataModel = \{.*?\};' outfile_temp -Poz | tail +2 | head -c 100

    extract embedded transcript from Sliq

        # version 1
        grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz |
        jq |  tr "{|}'" "\n" | sed 's/^,$//g'| grep $kw | printf "\n\n"

        # version 2
        grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz |
        jq -c '.en[] | {Begin,Content} ' | tr "{|}" "\ " | tr ",|\"" " "

        # version 3
        grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz | \
        jq '.en | select(.Content | contains("$kw")) | {Begin, Content}'

    extract transcript from VTT subtitles file

        curl $(targ) | grep -i '[a-z]' | sed  's/\r//g' | tr '\n' ' '

    make shortcut to allow any user to expand subtitles of file with URL in clipboard

        alias expvtt="curl $(xclip -selection clipboard -o) |
        grep -i '[a-z]' | sed  's/\r//g' | tr '\n' ' '

### livestream tools

* these were tested on Arizona's livestream, so ymmv.

    Download in 20 minute segments

        read -p "Target (url): " targ &&
        read -p "choose filename prefix: " outNAME &&
        targURL=$(curl -L $targ | tr "\'" "\n" |
            grep "\Khttp.*?media.*?m3u?8" -Poz | tr -d '\0') &&
            ffmpeg -i $targURL -c copy -segment_time 00:20:00 \
            -reset_timestamps 1 -f segment $outNAME%03d.mp4

    merge segments into single file and create audio-only file for easy transcription

        echo $(ls $outNAME*) | sed 's/ /\n/g' |  sed 's/^/file /g' > temp
        ffmpeg -f concat -i temp -c copy "${outNAME}_all.mp4" && rm temp &&
        ffmpeg -i "${outNAME}_all.mp4" -vn -ac 2 -b:a 192k "${outNAME}_all.mp3"

    download and run most up to date livestream ripper version from repo

        curl -sL https://raw.githubusercontent.com/jessicakay/glossy/refs/heads/main/livestream_rip.sh > liverip.sh &&
        source liverip.sh


### other scripts

* _[livestream_rip.sh](https://github.com/jessicakay/glossy/blob/main/livestream_rip.sh)_

    all-in-one script:

    * extracts source playlist from webpage
    * streams to ffmpeg, saving in user-specified intervals
    * once a user stops ripper using ctrl-c, removes last partial segment
    * merges all segments into unified files
    * extracts audio into separate mp3 for easy transcription

* _[transcript_tools.sh](https://github.com/jessicakay/glossy/blob/main/transcript_tools.sh)_

    * extracts transcripts from Sliq platform, VTT files

* _[stream_counter.sh](https://github.com/jessicakay/glossy/blob/main/stream_counter.sh)_

    * maps out site and displays livestreams, based on Rhode Island Capital TV website

* _detector_rip.sh](https://github.com/jessicakay/glossy/blob/main/_detector.sh)_

    all-in-one script:

    * combines most other scripts and code examples into a workflow
    * attempts to detect platform by looking for cues in URL and body of HTML
    * attempts to download through different types of curl request
    * livestream enumerator from _[stream_counter.sh](https://github.com/jessicakay/glossy/blob/main/stream_counter.sh)_


