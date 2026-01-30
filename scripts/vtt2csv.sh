# glossy vtt to csv converter
# jessdkant.bsky.social
#

# dos2unix -n file.vtt file2.vtt
# cat file2.vtt | sed 's/\ --> \|\n/\n/g' | awk '{print "\"" $0 "\","}' > temp
# cat temp | sed 's/\"\",//g' | tr "\n" " " | awk '{print "\t" $0}' | sed  's/  /\n/g' >  temp.csv

# version 1

# dos2unix temp.vtt
# cat temp.vtt | sed 's/\ --> \|\n/\n/g' | awk '{print "\"" $0 "\","}' > "${file_name}"
# printf "\"start\", \"end\", \"text\"" > "${file_name}_temp".csv
# cat $file_name | sed 's/\"\",//g' | tr "\n" " " |
#    awk '{print "\t" $0}' | sed  's/  /\n/g' >>  "${file_name}"_temp.csv
# tail -n +2 "${file_name}"_temp.csv > "${file_name}".csv
# head  -n 5 "${file_name}".csv

# version 2

read -p $'\nsource URL: ' sourceURL
read -p $'\nfilename (save as):' file_name
printf "\n"
if [ -f "temp.vtt" ]; then
    printf "temp.vtt already exists... \n"
    read -p "delete temp? [y/n]: " dtemp
    if [ $dtemp == "y" ]; then
        rm temp.vtt && printf "\n\n\t ~ cleared...\n"
        curl -q -L $sourceURL > temp.vtt
    else
        printf "\nquitting..\n"
        return
    fi
else
    curl -q -L $sourceURL > temp.vtt
fi


cat temp.vtt | tr -d '\0' > temp
printf "\n\n\t->" && dos2unix temp && printf "\n\n"
cat temp | sed 's/\ --> \|\n/\n/g' | awk '{print "\"" $0 "\","}' > "${file_name}"
cat $file_name | sed 's/\"\",//g' | tr "\n" " " |
    awk '{print "\t" $0}' | sed  's/  /\n/g' >  "${file_name}"_temp.csv
printf "\"start\", \"end\", \"text\",\n" > "${file_name}".csv
tail -n +2 "${file_name}"_temp.csv >> "${file_name}".csv
head  -n 5 "${file_name}".csv

# remove trailing comma
sed 's/.$//' ${file_name}.csv > "${file_name}"_temp.csv

printf "\n\t-> cleaning up temp files\n\n"
mv "${file_name}"_temp.csv "${file_name}".csv
rm "${file_name}"
