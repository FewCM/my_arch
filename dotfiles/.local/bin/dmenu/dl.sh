#!/usr/bin/env sh
DIR=~/Music
cd $DIR
target=$(echo "" | dmenu -fn "Iosevka Term" -p "Video")
qual=$(echo -e "3\n0\n1\n2\n4\n5\n6\n7\n8\n9" | dmenu -fn "Iosevka Term" -p Quality)
format=$(echo -e "mp3\nopus\nvorbis\nwav\nbest\naac\nflac\nm4a\n" | dmenu -fn "Iosevka Term" -p "Video")
youtube-dl -x --audio-format "$format" --audio-quality "$qual" "$target" 
