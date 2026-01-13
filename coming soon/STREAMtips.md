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

        grep '(?s)dataModel = \{.*?\};' outfile_temp -Poz | tail +2 | head -c 100

    extract transcript from Sliq 1

        grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz |  jq '.en | select(.Content | contains("$kw")) | {Begin, Content}'

    extract transcript from VTT subtitles file

        curl $(targ) | grep -i '[a-z]' | sed  's/\r//g' | tr '\n' ' '

    make shortcut to allow any user to expand subtitles of file with URL in clipboard

        alias expvtt="curl $(xclip -selection clipboard -o) |
        grep -i '[a-z]' | sed  's/\r//g' | tr '\n' ' '
