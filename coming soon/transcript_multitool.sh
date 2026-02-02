#
# transcript tools
#
# github.com/jessicakay/glossy
#
# jessdkant.bsky.social
#

read -p $'\n\t ~ search type? [e]mbedded or [d]irectory [a]rchive: ' s_type
read -p $'\n\t ~ Keyword (blank for save transcript): ' kw

case "$s_type" in
	e)
	read -p $'\n\t ~ Target (url): ' targ
	if [ $kw == "" ]; then
			transcript_filename=$(echo $targ | sed 's/[^a-z0-9]//gI' | tail -c 16)
			printf "\n\n" && curl $targ -o outfile_temp
			grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz |
			jq -c '.en[] | {Begin,Content} ' > "${transcript_filename}_transcript.JSON"
			cat ${transcript_filename}_transcript.JSON | \
				jq -r '.Content' | \
				tr "\n" "\ " > "${transcript_filename}_raw.txt"
			printf "\n\nsaved to \"${transcript_filename}\".\n"
	else
			printf "\n\n" && curl $targ -o outfile_temp &&
			printf "\n results: \n\n" &&
			grep '(?s)ccItems:\K\{\"en\"\:\[.*?\}\]\}' outfile_temp -Poz |
			jq -c '.en[] | {Begin,Content} ' |
				tr "{|}" "\ " | tr ",|\"" " " | grep -i $kw
			printf "\n"
	fi;;
#	d)
#	folder_name=$(echo $targ | grep -Po "http?s\:\/\/\K.*?\/" | sed 's/[\/."www"]//g')
#		curl -L $targ > outfile_temp
#        mkdir $folder_name && cd $folder_name
#        printf "\n\t ~ directory: $folder_name created\n"
#        wget $(cat outfile_temp | tr " " "\n" | grep -Po "http.*?.vtt") --random-wait | \
#		grep -Pi "$kw" *.vtt ; rm outfile_temp;;
#	*) return;;
	d)
		read -p $'\n\t ~ Target (url): ' targ
		folder_name=$(echo $targ | grep -Po "http?s\:\/\/\K.*?\/" | sed 's/[\/."www"]//g' )
		curl -L $targ > outfile_temp
        mkdir $folder_name && cd $folder_name
        printf "\n\t ~ directory: $folder_name created\n"
        cat ../outfile_temp | tr " " "\n" | grep -Po "http.*?.vtt" > file_list
        printf "\n\t -> located $( wc -l file_list ) VTT files"
        if [[ $(wc -l file_list ) > 0 ]]; then
			wget $(cat outfile_temp | tr " " "\n" | grep -Po "http.*?.vtt" ) --random-wait | \
			grep -Pi "$kw" *.vtt
		else
			printf "\n\t ~ $(cat ../outfile_temp | tr " " "\n" | \
				grep -Po "http.*?.m[4p][a3]" -c ) audio files found.\n"
		fi;;
	a)
		printf "\n\t -> searching...\n\n"
		cd /home/$( whoami )/glossy/transcripts/Cali
		mkdir results_temp
		grep -ir $kw */*.vtt > results_temp/results_temp.txt
		printf "\n\t ~ $(wc -l results_temp/results_temp.txt ) results found.\n\n"
		cd results_temp && head -n 5 results_temp.txt
		cut -c1-4 results_temp.txt | tr " " "\n" > r_year
		cut -c10-11 results_temp.txt | tr " " "\n" > r_month
		cut -c12-13 results_temp.txt | tr " " "\n" > r_day
		cut -c15- results_temp.txt | awk -F.vtt '{ print $1 }' > r_committee
		cut -c15- results_temp.txt | sed 's/.*://g' > r_text
		paste r_day r_month r_year -d '/' > r_date
		cat r_text | awk '{print "\"" $0 "\"" }' > rtext_clean
		echo "date,day,month,year,committee,text" > results.csv
		paste -d ',' r_date r_day r_month r_year r_committee rtext_clean >> results.csv
		printf "\n\t -> cleaning up...\n" && mv results.csv ../.
		cd /home/$( whoami )/glossy/transcripts/Cali
		rm -r results_temp/ && printf "\n\n\t -> generating json...\n\n"
		head -n 2 results.csv | csvjson | jq
		csvjson results.csv | jq > results.json
		printf "\n\t ~ csv and json saved in " && pwd && echo -e '\n\n';;
	*) return;;
esac
# empty keyword saves transcript to filename using last 16 characters of URL string

