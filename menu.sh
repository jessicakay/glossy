
if [[ -z $(alias | grep "liverip") ]]; then
    alias liverip="source livestream_rip.sh";
    echo -e "\nliverip alias added to current env\n"
    echo 'alias liverip="source livestream_rip.sh"' >> ~/.bashrc
    printf "added to ~/.bashrc"
else
    printf "shortcut liverip exists\n"
fi

if [[ -z $(alias | grep "ts_tools") ]]; then
    alias ts_tools="source transcript_tools.sh";
    echo -e "\nts_tools alias added to current env\n"
    echo 'alias ts_tools="source transcript_tools.sh"' >> ~/.bashrc
    printf "added to ~/.bashrc"
else
    printf "shortcut ts_tools exists\n"
fi

if [[ -z $(alias | grep "streamcount") ]]; then
    alias ts_tools="source stream_counter.sh";
    echo -e "\nstreamcount alias added to current env\n"
    echo 'alias streamcount="source streamcount.sh"' >> ~/.bashrc
    printf "added to ~/.bashrc"
else
    printf "shortcut streamcount exists"
fi
