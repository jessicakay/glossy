# glossy

### tips from [jessk.org/blog/streamripping-democracy](https://https://jessk.org/blog/streamripping-democracy)

For background on this project, check out the [blog post](https://https://jessk.org/blog/streamripping-democracy) above. In short: while there are amazing ffmpeg wrappers like [yt-dlp](https://github.com/yt-dlp/yt-dlp) out there, they tend to fall short when it comes to legislative, municipal and judicial hearings which run on platforms that try and limit this, and typically don't include tools for transcription.

The [first section](https://github.com/jessicakay/glossy) is meant for users to follow along to the tutorial and learn the basics of archiving videos and downloading livestreams. THe second, however, contains scripts in progress for expanding these capabilities and automating the process of identifying platforms and configuring ffmpeg. You can find those [here](https://github.com/jessicakay/glossy#other-scripts).

## install packages

* code snippets are written in bash. You can either use them natively in linux (tested on ubuntu), or download [Cygwin](https://www.cygwin.com/) or [Linux Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install). The syntax will be different for shell environments but once pacakges are installed, the rest of this should work on any linux shell wth minimal tweaking.

* basic packages

    > for apt package manager (ubuntu/debian):

        sudo apt update && sudo apt install ffmpeg jq xclip

    > for homebrew (macOS and most linux flavors):

        brew update
        brew install ffmpeg jq xclip


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

* Arizona has a placeholder URL for their livestream. using the _grep -L_ location tag instructs the computer to follow the redirect to the destination, otherwise the placeholder 301 redirect page gets loaded into buffer.

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

    run WhisperX LLM transcription in separate window

        # requires  --segment_list $outNAME.m3u8 in command stack for ripper
        # must have whisper installed

        watch -g -n 1 --no-title grep -oE 'outNAME[0-9]+.mp4' $outNAME.m3u8 &&
        tail -n 1 $outNAME.m3u8 | whisper --language English --model base.en \
        --verbose True --task transcribe --output_format txt

    download and run most up to date livestream ripper version from repo

        curl -sL https://bit.ly/4sE4a1X > liverip.sh && source liverip.sh


## other scripts

## install packages

* to install advanced packages

    > python

        sudo apt update &&
        sudo apt install python3-selenium
        python -m pip install --upgrade pip
        pip install -U openai-whisper

### examples of more complex scripts using code snippets above

* _[livestream_rip.sh](https://github.com/jessicakay/glossy/blob/main/scripts/livestream_rip.sh)_

    all-in-one script:

    * extracts source playlist from webpage
    * streams to ffmpeg, saving in user-specified intervals
    * once a user stops ripper using ctrl-c, removes last partial segment
    * merges all segments into unified files
    * extracts audio into separate mp3 for easy transcription

* _[transcript_tools.sh](https://github.com/jessicakay/glossy/blob/main/scripts/transcript_tools.sh)_

    * extracts transcripts from Sliq platform, VTT files

* _[stream_counter.sh](https://github.com/jessicakay/glossy/blob/main/scripts/stream_counter.sh)_

    * maps out site and displays livestreams, based on Rhode Island Capital TV website

* _[detector_rip.sh](https://github.com/jessicakay/glossy/blob/main/scripts/detector.sh)_

    all-in-one script:

    * combines most other scripts and code examples into a workflow
    * attempts to detect platform by looking for cues in URL and body of HTML
    * attempts to download through different types of curl request
    * livestream enumerator from _[stream_counter.sh](https://github.com/jessicakay/glossy/blob/main/stream_counter.sh)_


