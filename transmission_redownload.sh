#!/bin/bash

# Copyright Arie van Dobben 14 March 2015
#
# This script removes and re-adds all torrents that have the 'No data found!' error message.
#
# It can be useful to re-add torrents if one has lost the original data, but Transmission 
# still has reference to the original torrents. Also the original file location will be 
# restored if it does not exist anymore.
# Works with:
#  transmission-remote 2.82 (14160)
#  GNU bash, version 4.3.11(1)-release-(x86_64-pc-linux-gnu)
#  Linux server 3.13.0-46-generic #79-Ubuntu SMP Tue Mar 10 20:06:50 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
#  Ubuntu 14.04
#  
# Transmission stores all current torrents in '/etc/transmission-debian/torrents'. Copy all torrent 
# files to a temp dir and change ownership (chown) to the user who is going to run this script. 
# After successful running this script the tempdir with torrents can be deleted.

# Transmission must be remotely accessible, this can be changed in the config file. A username and password are required.

# Change below parameters to your setup:
tempdir="/home/user/temptor"  # temporary dir where torrents are stored
server="server"               # ip address where transmission is running
port="port"                   # port transmission listens to for remote access
username="username"           # username
password="password"           # password
maxid=800                     # The maximum ID can be obtained by running in shell (it will be last number):
                              # transmission-remote server:host -n username:password -l | sed 's/\([0-9]*\).*/\1/'

#First create an array of all torrents ids that have the "No data found!" error message:
errnos=()

for tn in `seq 1 "$maxid"`
do
    grepline=$(transmission-remote "$server":"$port" -n "$username":"$password" -t"$tn" -i | grep 'No data found\! Ensure your drives')
    if [[ "$grepline" == *"No data found"* ]]
    then
        errnos+=($tn)
    fi
done

#echo ${errnos[@]}

#Next loop through the array and do the following:
# 1. Copy file download location
# 2. Copy torrent hash (torrent files are stored in /etc/transmission-debian/torrents with part of hash in filename
# 3. Create file path if not exists already
# 4. find temporary torrent in tempdir using part of hash
# 5. Delete torrent
# 6. Re-add torrent with correct file path

for num in ${errnos[@]}
do
   echo "ID: $num"

   location=$(transmission-remote "$server":"$port" -n "$username":"$password" -t"$num" -i | \
      grep -e "Location:" | sed 's/\s\s[A-Za-z]*:\s//g')
   echo "Location: $location"

   infohash=$(transmission-remote "$server":"$port" -n "$username":"$password" -t"$num" -i | \
      grep -e "Hash:" | sed 's/\s\s[A-Za-z]*:\s//g')
   echo "Hash: $infohash"

   tname=$(transmission-remote "$server":"$port" -n "$username":"$password" -t"$num" -i | \
      grep -e "Name:" | sed 's/\s\s[A-Za-z]*:\s//g')
   echo "Name: $tname"
   
   #test if location exists, if not, create it (-p also parents)
   echo "Checking for location $location"
   [[ -d $location ]] || mkdir -p "$location"

   #torrents are located in tempdir with filename like "Voodoo - 2000.a300d85533695019.torrent"
   echo "Searching for torrent with hash ${infohash:0:16}"
   torfile=$(find "$tempdir" -name *"${infohash:0:16}"*)

   #remove current torrent
   echo "Removing torrent $tname"
   transmission-remote "$server":"$port" -n "$username":"$password" -t"$num" --remove
   
   #add torrent with correct file path
   echo "Adding torrent $torfile with location $location"
   transmission-remote "$server":"$port" -n "$username":"$password" --add "$torfile" --download-dir "$location"
   
done
