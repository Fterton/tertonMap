# tertonMap
Shell script that use common commands to scan networks (used on Kali)
Default nmap command used is : nmap -sV -sC "$network" 

## usage
Usage: ./tertonMap.sh [options] \
Options: \
  -n <network>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Specify the network to scan (e.g., 192.168.1.1 or 192.168.1.0/24) \
  -z <zip>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Specify the name of the zip to create \
  --h[elp]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Show this help message \
  --vuln&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Use NSE vuln scripts \
  --password&nbsp;&nbsp;&nbsp;&nbsp;Set a password for the zip file \
  --hostinfos&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Retrieve only current host infos, dont scan networks

If the network is not specified, tertonMap will scan all interfaces (except the loopback interface).

## sample commands

./tertonMap.sh \
\
The script will run some commands to retrieve informations from the host (such as name, IP addresses, WiFi scan, etc.). \
Next, the script will scan interfaces. \
For each interface, the script will perform an Nmap command with XML output. The XML files are then transformed into HTML files. 

./tertonMap.sh -z myScan.zip --password --vuln \
\
With this options, the script will first prompt you for a password. \
Then it will do the same as previous sample but nmap command is run with "--script vuln" option and all the generated files are packaged into a zip file with the given password and the original files are deleted. 

./tertonMap.sh -n 192.168.1.0/24 -z myScan.zip --password --vuln 
\
Do the same as previous sample but dont scan interfaces and nmap the network 192.168.1.0/24

