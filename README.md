# make_playlist

This is a Bash script for creating music playlists in the m3u format. The playlists consist only of straight filenames of mp3 files. The script is developed for Linux bash shell and requires the bc package to be installed.

## Features
The script provides several ways to create a playlist:

### Playlist based on a directory and its subdirectories: 
The script prompts the user to select a directory. The playlist will consist of all mp3 files in the selected directory and its subdirectories.

### Set keywords to define playlist content: 
The user can input keywords (such as artist or album names) to define the content of the playlist. The script will search for mp3 files in the selected directory and its subdirectories that match the keywords.

### Limit the maximum duration of songs to be included in the playlist: 
The user can specify a maximum duration (in minutes) for songs to be included in the playlist. The script will exclude songs that exceed this duration.

### Include only files that have been added or modified after a certain date: 
The user can specify a date, and the script will include only files that have been added or modified after this date.

## Usage
Place the script make_playlist.sh into the directory $HOME/funkRadio/. To activate the script, type 'chmod +x $HOME/funkRadio/make_playlist.sh'. To run the script, type 'HOME/funkRadio/make_playlist.sh'.

When launched, the script will present a menu with options listed above in Features. Select an option by typing its corresponding number and pressing Enter.

The script will then guide you through the process of creating a playlist. The resulting playlist will be saved in the directory $HOME/funkRadio.
