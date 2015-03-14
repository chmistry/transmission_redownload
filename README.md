# transmission_redownload
This script removes and re-adds all torrents that have the 'No data found!' error message.

Config the script as described below and run it via:
```bash
./transmission_redownload.sh
```

It can be useful to re-add torrents if one has lost the original data, but Transmission 
still has reference to the original torrents. Also the original file location will be 
restored if it does not exist anymore. 

Works with:
- transmission-remote 2.82 (14160) 
- GNU bash, version 4.3.11(1)-release-(x86_64-pc-linux-gnu) 
- Ubuntu 14.04 
- Linux server 3.13.0-46-generic #79-Ubuntu SMP Tue Mar 10 20:06:50 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux 

Transmission stores all current torrents in '/etc/transmission-debian/torrents' copy all torrent 
files to a temp dir and change ownership (chown) to the user who is going to run this script. 
After successful running this script the tempdir with torrents can be deleted.

Transmission must be remotely accessible, can be changed in the config file. A username and password are required.

Change below parameters to your setup:
```bash
tempdir="/home/user/temptor"  # temporary dir where torrents are stored
server="server"               # ip address where transmission is running
port="port"                   # port transmission listens to for remote access
username="username"           # username
password="password"           # password
maxid=800                     # The maximum ID can be obtained by running in shell (it will be last number):

transmission-remote server:host -n username:password -l | sed 's/\([0-9]*\).*/\1/'
```
