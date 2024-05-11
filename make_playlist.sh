#!/bin/bash

# This script makes music playlists of the m3u format.
# The playlists consist only of straight filenames of mp3 files.

# Developed for Linux bash shell.

# Please make sure that you have installed the following packages:
# - bc # Needed for calculations.

select_by_number () {
clear
PS3="Please type number corresponding to directory that contains mp3 music files."
select d in */
do
  test -n "$d" && break
  echo ">>> Invalid Selection"
done
fav="$PWD"/"$d"

echo "Dig deeper (type 1) or make a playlist consisting of mp3 files in directory $fav (type Enter)"
read -r choice
if [[ $choice == 1 ]]
then
  cd "$fav"
  select_by_number
else
  :
fi
}

select_music_directory () {
# Go to the home directory.
cd "$HOME/"
# type a number to select the corresponding directory:
select_by_number

IFS= read -re -i "$fav" -p 'Please accept (Enter) or edit the following: ' fav
lastchar=${fav: -1}
if [[ $lastchar != / ]]
then
  fav="$fav"/
fi
echo "Music playlist will be based on "$fav" and its subdirectories."

# Identifying the filename of the selected directory.
upperdir=$(echo "$fav" | awk -F "/" '{print $(NF-1)}')
upperdir=$(echo "${upperdir// /_}")
}

# make_playlist

make_playlist () {
if [[ "$playlist_scope" = "chosen_directory" ]]
then
  chosen_directory=$(echo "$fav" | awk -F "/" '{print $(NF-1)}')
  # echo ${a// /_}
  chosen_directory=$(echo "${chosen_directory// /_}")
  Playlist="$HOME/funkRadio/$chosen_directory.m3u"
  if [ -f "${Playlist}" ]; then echo "" > "${Playlist}"; fi
  find "$fav" -type f -iname "*.mp3" -exec echo {} \; >> "${Playlist}_1" 
  sed -i -e '/\.mp3$/!d' "${Playlist}_1"
  sort "${Playlist}_1" > "${Playlist}"
  Playlist="${Playlist// /_}"
  nano "${Playlist}"
  rm "${Playlist}_1"
  exit
fi

# ------------

if [[ "$playlist_scope" = "keywords" ]]
then

# Next, we set keywords that are used in building the playlist: names of music 
# directories, artists, etc.
# Build the playlist by typinng "start".  


number_of_searched_words=0
  search_decision=just_to_get_started
  until [ "${search_decision}" = "start" ]
  do
      echo "Type a keyword \(only one at a time\) - music directory, artist etc. - to set up the playlist. Typing keyword 'start' will build the playlist."
      read search_decision
      if [ "${search_decision}" != "start" ]
      then
          searched_words[$number_of_searched_words]="${search_decision}"
          ((number_of_searched_words++))
      fi
  done

  echo "Number of words searched for playlist:" "$number_of_searched_words"
  keywords_for_playlist="$(printf "%s" "${searched_words[@]}")"
  echo "Playlist is based on the following keywords: ${keywords_for_playlist}"
  Playlist=$HOME/funkRadio/"$keywords_for_playlist".m3u
  
  if [ -f "${Playlist}" ]; then echo "" > "${Playlist}"; fi

  for i in "${searched_words[@]}"
  do
    music_descriptor="${i}"
    IFS=$'\n'
    for song in $(find "${fav}" -type f -name "*.mp3" -print | grep -i "${music_descriptor}")
    do
      echo "${song}" >> "${Playlist}"
    done
  done
  nano "${Playlist}"
  exit
fi

# ------------

if [[ "$playlist_scope" = "duration" ]]
then
  IFS=$'\n' 
  echo "Please type maximum duration of songs in minutes."
  read max_dur
#   find "$fav" -name '*.mp3' -exec ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 {} \; | awk -v max_dur="$max_dur" '{if ($1 < max_dur * 60) -printf "%p \n"}' > ~/funkRadio/"$fav"_playlist.m3u
#   exit

  if [ "$max_dur" -eq "$max_dur" ] 2>/dev/null # Testing if "$max_dur" is a number.
  then
    max_dur_sec=$(( 60 * $max_dur ))
  fi
  # echo "$fav" "$max_dur_sec"

  Playlist=$HOME/funkRadio/"${upperdir}_${max_dur}"min.m3u
  
  if [ -f "${Playlist}" ]; then echo "" > "${Playlist}"; fi

  for song in $(find "$fav" -type f -name "*.mp3")
  do  
    # echo "${song}"
    piece_dur="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${song} | tr -d '\r')"
    # echo "$piece_dur" "$max_dur_sec"
    if (( $(echo "$piece_dur < $max_dur_sec" | bc -l) ))
    then
     echo "${song}" >> "${Playlist}"
    fi
  done
  nano "${Playlist}"
  exit
fi


# ------------

if [[ "$playlist_scope" = "past_date" ]]
then
  # Ask user to give a date from which the files are included in the playlist.
  # The date is in the format YYYY-MM-DD.
  echo "Give a date in the format YYYY-MM-DD. Songs added or modified after that are to be included in the playlist."
  read -p "Date: " start_date
  # Make a m3u playlist based on the date of the files in the directory "$fav" and save it to ~/funkRadio/Jazz_"$start_date".m3u
  # The date is in the format YYYY-MM-DD.
  # Playlist="${Playlist}"_"$start_date".m3u
  # Playlist=$HOME/funkRadio/"$start_date".m3u
  Playlist=$HOME/funkRadio/"${upperdir}_${start_date}".m3u
  if [ -f "${Playlist}" ]; then echo "" > "${Playlist}"; fi
  # find "$fav" -type f -iname "*.mp3" -newermt "$start_date" -print0 | sort -z | xargs -0 -I % echo "file '%'" > "${Playlist}"
  find "$fav" -type f -iname "*.mp3" -newermt "$start_date" -print0 | sort -z | xargs -0 -I % echo "%" > "${Playlist}"
  sed -i -e '/\.mp3$/!d' "${Playlist}"
  nano "${Playlist}"
  exit
fi
}

# ------------

control_panel () {
while true
do
clear
cat <<- end
1 Playlist based on a directory and its subdirectories.
2 Set keywords to define playlist content. Use artist or album name etc. Type 'start' to build playlist.
3 Limit the maximum duration of songs to be included in the playlist.
4 Include only songs that have been added or modified after a certain date.
5 Do not make a playlist - quit instead.
end

  echo "Type one of the listed numbers to do what you want."
  read selected_number
  case "$selected_number" in
  "1")
      # echo "First select directory on which \(and subdirectories of which\) playlist will be based."
      select_music_directory
      playlist_scope="chosen_directory"
      make_playlist
      ;;
  "2")
      # echo "Set keywords to be used in building the playlist. Build by typing 'start'."
      select_music_directory
      playlist_scope="keywords"
      make_playlist
      ;;
  "3")
      # echo "Limit duration of songs  in the playlist."
      select_music_directory
      playlist_scope="duration"
      make_playlist
      ;;
  "4")
      # echo "Include only songs added or modified after a date. Next, give that date in the yyyy-mm-dd format."
      select_music_directory
      playlist_scope="past_date"
      make_playlist
      ;;
  "5")
      echo "No new playlist was made."
      exit
      ;;
  *) echo "Invalid option."
      ;;
  esac
done
}

# =================================
# THE MAIN PART OF THE SCRIPT - USER INTERACTIONS START HERE
# =================================

# The action starts from the control panel.

control_panel

# The location of the script is $HOME/funkRadio/make_playlist.sh
