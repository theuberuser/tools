#!/bin/bash

# A dumb tool I wrote for a prompt in Music League (https://musicleague.com/)
# Features to add:
# - Add Spotify library support
# - Search for songs with BPM X
# - Search for songs that contain word
# - Search for songs with feat.
# - Search for songs by Mix type
# - Search for songs with more than one artist
# - Search for songs on release date
# - Search for songs with length
# - Search for songs by artist X
# - Search for songs by label X

if [[ $# -lt 2 ]]; then
    COUNT=5
    directory="$(pwd)"
    echo "Arguments blank. Using defaults"
else
  directory=$1
  COUNT=$2
fi

songs=()
temp_file=$(mktemp)
PATTERN="^([0-9]+)?(.* -)?( |_)?(.*)( |_)(\((.*)?\)|\[(.*)?\])(.*)?\.(mp3|wav|m4a|aiff|flac)$"

if [ ! -d $directory ]; then
  echo "ERROR: The directory ${directory} does not exist"
  exit 1
fi

if [[ ! $COUNT =~ [0-9]+ ]]; then
  echo "ERROR: Count must be a number"
  exit 1
fi

find "$directory" -type f \( -name "*.mp3" -o -name "*.wav" -o -name "*.m4a" -o -name "*.aiff" -o -name "*.flac" \) > "$temp_file"

total_songs=$(awk 'END {print NR}' "$temp_file")

if [[ $total_songs == "0" ]]; then
  echo "Could not find any music files in directory $directory"
  exit 1
fi

echo "Scanning ${total_songs} files for songs that contain ${COUNT} letters...."

while read -r file; do
    filename=$(basename "$file")
    if [[ "$filename" =~ $PATTERN ]]; then
        song="${BASH_REMATCH[4]}"
    else
        song="${filename%.*}"
    fi
    
    if [[ $song =~ ^[a-zA-Z]{$COUNT}$ ]]; then
        name=$(echo "$filename" |sed -E 's/(_PN)?\.(mp3|wav|m4a|aiff|flac)//g')
        songs+=("$name")
    fi
done < "$temp_file"

rm -f "$temp_file"

NUM_MATCHES="${#songs[@]}"

if [ $NUM_MATCHES -eq 0 ]; then
  echo "Found zero songs with $COUNT letters"
else
  echo -e "Found ${NUM_MATCHES} songs:\n"
  sleep 5

  sorted_songs=()
  while IFS= read -r song; do
      sorted_songs+=("$song")
  done < <(printf "%s\n" "${songs[@]}" | sort -u)

  for song in "${sorted_songs[@]}"; do
      echo "Title: $song"
  done
fi
