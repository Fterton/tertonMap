# tertonMap
Shell script that use common commands to scan networks (used on Kali)

## usage
Usage: ./tertonMap.sh [options]
Options:
  -n <network>         Specify the network to scan (e.g., 192.168.1.1 or 192.168.1.0/24)
  -z <zip>             Specify the name of the zip to create
  --h[elp]             Show this help message
  --vuln               Use NSE vuln scripts
  --password           Set a password for the zip file
  --hostinfos          Retrieve only current host infos, dont scan networks


