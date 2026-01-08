#
# transcript tools
#
# github.com/jessicakay/glossy
#
# jessdkant.bsky.social
#

# empty keyword saves transcript to filename using last 16 characters of URL string
read -p "Target (url): " targ && read -p "Keyword (blank for save transcript): " kw
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
fi
