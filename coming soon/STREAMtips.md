# glossy

### tips from [jessk.org/blog/streamripping-democracy](https://https://jessk.org/blog/streamripping-democracy)

## install packages

        sudo apt install ffmpeg jq xclip

### basic scripts

* find mp4 on page, copy from ffmpeg

read -p "Target (url): " targ && ffmpeg -i $(curl -s $targ |
        grep "\Khttps.*?mp4" -oPm 1) -c copy outfile.mp4

* find stream and rip to ffmpeg

        read -p "Target (url): " targ && ffmpeg -i $(curl $targ | \
        grep "\Khttps.*?m3u" -oP | grep "https" -m 1) -c copy outfile.mp4

* granicus

        read -p "Target (url): " targ && ffmpeg -i $(curl $targ -L |
        tr "\'" "\n" |  grep "\Khttp.*?m3u?8" -Poz |
        grep "m3u" -z -m 1) -c copy out.mp4

* pull whole data model from Sliq, only show first 100 characters

        grep '(?s)dataModel = \{.*?\};' outfile_temp -Poz | tail +2 | head -c 100

* extract transcript from embedded VTT subtitles file

        curl $(targ) | grep -i '[a-z]' | sed  's/\r//g' | tr '\n' ' '

* make shortcut to allow any user to expand subtitles of file with URL in clipboard

        alias expvtt="curl $(xclip -selection clipboard -o) | grep -i '[a-z]' | sed  's/\r//g' | tr '\n' ' '
