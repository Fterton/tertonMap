# tertonMap
Shell script that use common commands to scan networks (used on Kali)

## usage
Usage: ./tertonMap.sh [options] \
Options: \
  -n <network>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Specify the network to scan (e.g., 192.168.1.1 or 192.168.1.0/24) \
  -z <zip>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Specify the name of the zip to create \
  --h[elp]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Show this help message \
  --vuln&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Use NSE vuln scripts \
  --password&nbsp;&nbsp;&nbsp;&nbsp;Set a password for the zip file \
  --hostinfos&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Retrieve only current host infos, dont scan networks


