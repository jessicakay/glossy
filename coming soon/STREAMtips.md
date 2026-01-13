# glossy

### tips from [jessk.org/blog/streamripping-democracy](https://https://jessk.org/blog/streamripping-democracy)

* install packages

        * read -p "Target (url): " targ && ffmpeg -i $(curl -s $targ | grep "\Khttps.*?mp4" -oPm 1) -c copy outfile.mp4

find stream and rip to ffmpeg

        * read -p "Target (url): " targ && ffmpeg -i $(curl $targ | grep "\Khttps.*?m3u" -oP | grep "https" -m 1) -c copy outfile.mp4

### other scripts

