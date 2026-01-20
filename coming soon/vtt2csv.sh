# glossy vtt to csv converter
# jessdkant.bsky.social
#

# dos2unix -n file.vtt file2.vtt
# cat file2.vtt | sed 's/\ --> \|\n/\n/g' | awk '{print "\"" $0 "\","}' > temp
# cat temp | sed 's/\"\",//g' | tr "\n" " " | awk '{print "\t" $0}' | sed  's/  /\n/g' >  temp.csv

read -p $'\nsource URL: ' sourceURL
read -p $'\nfilename (save as):' file_name
if [ -f "temp.vtt" ]; then
    printf "temp.vtt already exists... exiting."
    return
else
    curl -q $sourceURL > temp.vtt
fi

dos2unix temp.vtt
cat temp.vtt | sed 's/\ --> \|\n/\n/g' | awk '{print "\"" $0 "\","}' > "${file_name}"
cat $file_name | sed 's/\"\",//g' | tr "\n" " " |
    awk '{print "\t" $0}' | sed  's/  /\n/g' >  "${file_name}"_temp.csv
tail -n +2 "${file_name}"_temp.csv > "${file_name}".csv
head  -n 5 "${file_name}".csv

