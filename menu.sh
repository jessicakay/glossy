
echo -e "choose session type\n"
read -p $'[L]ocal .env\n[P]rofile ~/.bashrc\n[B]oth>' s_c

if [[ $s_c == "b" ]] || [[ $s_c == "l" ]]; then
    if [[ -z $(alias | grep "liverip") ]]; then
        alias liverip="source livestream_rip.sh";
        echo -e "\nliverip alias added to current env\n"
    else
        printf "shortcut liverip exists\n"
    fi
    if [[ $s_c == "b" ]] ||  [[ $s_c == "p" ]]; then
        echo 'alias liverip="source livestream_rip.sh"' >> ~/.bashrc
        printf "added to ~/.bashrc"
    fi
else
        printf "\nnot a valid choice\n"
fi

if [[ $s_c == "b" ]] || [[ $s_c == "l" ]]; then
    if [[ -z $(alias | grep "ts_tools") ]]; then
        alias ts_tools="source transcript_tools.sh";
        echo -e "\nts_tools alias added to current env\n"
    else
        printf "shortcut ts_tools exists\n"
    fi
    if [[ $s_c == "b" ]] || [[ $s_c == "p" ]]; then
            echo 'alias ts_tools="source transcript_tools.sh"' >> ~/.bashrc
            printf "added to ~/.bashrc"
    fi
else
    printf "\nnot a valid choice\n"
fi

if [[ $s_c == "b" ]] || [[ $s_c == "l" ]]; then
    if [[ -z $(alias | grep "streamcount") ]]; then
        alias streamcount="source stream_counter.sh";
        echo -e "\nstreamcount alias added to current env\n"
   else
        printf "shortcut streamcount exists"
    fi
    if [[ $s_c == "b" ]] || [[ $s_c == "p" ]]; then
        echo 'alias streamcount="source streamcount.sh"' >> ~/.bashrc
        printf "added to ~/.bashrc"
    fi
else
    printf "\nnot a valid choice\n"
fi
