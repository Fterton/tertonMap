#!/bin/bash

# Function to retrieve host informations and archive generated informations file
perform_host_infos_and_archive() {
    local archive_name="$1"
    local encryption_password="$2"

    host_infos_file="host_infos.txt"

    echo 
    echo ------------------------------------------
    echo
    echo RETRIEVING HOST INFORMATIONS
    echo
    echo Zip Name :       $archive_name
    if [ -n "$encryption_password" ]; then echo Zip Password : yes
        else echo Zip Password : no
    fi
    echo host_infos_file : $host_infos_file
    echo
    echo ------------------------------------------
    echo 

    sudo rm -f "$host_infos_file"

    echo ------------------------------------------ >> $host_infos_file
    echo uname -a >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    uname -a >> $host_infos_file
    echo >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo ip addr >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    ip addr >> $host_infos_file
    echo >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo wget -qO- icanhazip.com >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    wget -qO- icanhazip.com >> $host_infos_file
    echo >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo hciconfig >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    hciconfig >> $host_infos_file
    echo >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo hcitool scan >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    hcitool scan >> $host_infos_file
    echo >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo iwconfig >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    iwconfig >> $host_infos_file
    echo >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo iwlist wlan0 scan >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    iwlist wlan0 scan >> $host_infos_file
    echo >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo sudo iwlist scan >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    sudo iwlist scan >> $host_infos_file
    echo >> $host_infos_file
    
    echo ------------------------------------------ >> $host_infos_file
    echo mtr -r -c 1  8.8.8.8 >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    mtr -r -c 1  8.8.8.8  >> $host_infos_file
    echo >> $host_infos_file

    archive_files "$archive_name" "$encryption_password" "$host_infos_file" 

    echo 
    echo ------------------------------------------
    echo
    echo END OF RETRIEVING HOST INFORMATIONS
    echo
    echo ------------------------------------------
    echo 

}

# Function to execute netdiscover, Nmap, transform report to HTML, make an archive of all generated files
perform_scan_and_archive() {
    local network="$1"
    local use_vuln_script="$2"
    local archive_name="$3"
    local encryption_password="$4"
    local interface="$5"

    local output_file=$(echo "$network" | sed 's/\//_/g').xml
    local output_file_html=$(echo "$network" | sed 's/\//_/g').html

    netdiscover_file="netdiscover.txt"

    if [ -n "$interface" ]; then
        netdiscover_file="netdiscover_"$interface".txt"
    fi

    echo 
    echo ------------------------------------------
    echo
    echo RETRIEVING NETWORK INFORMATIONS
    echo
    echo Interface :          $interface  
    echo Network :            $network
    echo Output File :        $output_file
    echo Output HTML File :   $output_file_html  
    echo Use Vuln Script :    $use_vuln_script
    echo Zip Name :           $archive_name
    if [ -n "$encryption_password" ]; then echo Zip Password : yes
        else echo Zip Password : no
    fi
    echo netdiscover_file :   $netdiscover_file
    echo
    echo ------------------------------------------
    echo 

    perform_netdiscover_scan "$interface" "$network" "$netdiscover_file"
    perform_nmap_scan "$network" "$output_file" "$use_vuln_script"
    generate_html_report "$output_file" "$output_file_html"
    archive_files "$archive_name" "$encryption_password" "$output_file" "$output_file_html" "$netdiscover_file"

    echo 
    echo ------------------------------------------
    echo
    echo END OF RETRIEVING NETWORK INFORMATIONS
    echo
    echo ------------------------------------------
    echo


}

# Function that archive files 
archive_files() {
    local archive_name="$1"
    local encryption_password="$2"
    local file1="$3"
    local file2="$4"
    local file3="$5"


    # Create archive and encrypt if password is provided
    if [ -n "$archive_name" ]; then
        echo 
        echo ------------------------------------------
        echo "Updating archive $archive_name..."
        
        if [ -n "$encryption_password" ]; then
            # Add files to zip file whith password
            sudo zip -q -r --password "$encryption_password" "$archive_name" "$file1" "$file2" "$file3"
        else
            # Add files to zip file whithout password
            sudo zip -q -r "$archive_name" "$file1" "$file2" "$file3"
        fi

        # Check if zip was successfull 
        if [ $? -eq 0 ]; then
            echo "Zip $archive_name updated."
            echo ------------------------------------------
            echo

            # Delete original files
            sudo rm -f "$file1" "$file2" "$file3"
        else
            echo "Failed to update zip $archive_name."
        fi
    fi
}


# Function that perform a netdiscover scan
perform_netdiscover_scan() {
    local interface="$1"
    local network="$2"
    local netdiscover_file="$3"

    sudo rm -f "$netdiscover_file"

    echo 
    echo ------------------------------------------
    echo "Running netdiscover..."
    echo 

    # Note - Fast netdiscover without known range : sudo netdiscover -i wlan0 -f

    if [ -n "$interface" ]; then
        echo ------------------------------------------ >> $netdiscover_file
        echo "sudo netdiscover -s 3 -c 3 -i $interface -r $network -P " >> $netdiscover_file
        echo ------------------------------------------ >> $netdiscover_file
        sudo netdiscover -i $interface -r $network -P  >> $netdiscover_file
    else
        echo ------------------------------------------ >> $netdiscover_file
        echo "sudo netdiscover -s 3 -c 3 -r $network -P " >> $netdiscover_file
        echo ------------------------------------------ >> $netdiscover_file
        sudo netdiscover -r $network -P  >> $netdiscover_file
    fi

    echo
    echo "End of running netdiscover..."
    echo ------------------------------------------
    echo

}

# Function to execute Nmap
perform_nmap_scan() {
    local network="$1"
    local output_file="$2"
    local use_vuln_script="$3"

    echo 
    echo ------------------------------------------
    echo 
    if [ "$use_vuln_script" = true ]; then
        echo "Scanning network $network with vuln scripts..."
        sudo nmap -sV -sC --script vuln "$network" -oX "$output_file"
    else
        echo "Scanning network $network..."
        sudo nmap -sV -sC "$network" -oX "$output_file"
    fi

    echo
    echo "Scan of $network completed. Results saved in $output_file"
    echo ------------------------------------------
    echo
}

# Function to make html report from XML report
generate_html_report() {
    local xml_file="$1"
    local html_file="$2"

    echo 
    echo ------------------------------------------
    echo "Making html report $html_file from xml result $xml_file ..."
    echo 

    sudo xsltproc "$xml_file" -o "$html_file"

    echo 
    echo "HTML report saved in $html_file"
    echo ------------------------------------------
    echo 
}

# Function to encryp results  
# Changed with zip password
# encrypt_file() {
#     local input_file="$1"
#     local output_file="$2"
#     local password="$3"
# 
#     echo 
#     echo ------------------------------------------
#     echo "Encrypting $input_file..."
#     echo ------------------------------------------
#     echo 
#     
#     sudo openssl enc -aes-256-cbc -salt -in "$input_file" -out "$output_file" -pass pass:"$password"
# }

# Function to display help
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -n <network>         Specify the network to scan (e.g., 192.168.1.1 or 192.168.1.0/24)"
    echo "  -z <zip>             Specify the name of the zip to create"
    echo "  --h[elp]             Show this help message"
    echo "  --vuln               Use NSE vuln scripts"
    echo "  --password           Set a password for the zip file"
    echo "  --hostinfos          Retrieve only current host infos, dont scan networks"
    
    exit 1
}

# Init defaults
network_to_scan=""
use_vuln_script=false
archive_name=""
encryption_password=""
hostinfos_only=false

# Analyze command options
while getopts ":z:n:-:-:-:" opt; do
    case $opt in
        n)
            network_to_scan="$OPTARG"
            ;;
        z)
            archive_name="$OPTARG"
            ;;
        -)
            case "${OPTARG}" in
                vuln)
                    use_vuln_script=true
                    ;;
                password)
                    read -s -p "Enter a password for zip: " encryption_password
                    echo
                    read -s -p "Confirm password for zip: " encryption_password_confirm
                    echo

                    # Check if passwords are differents
                    if [ "$encryption_password" != "$encryption_password_confirm" ]; then
                        echo "Passwords do not match. Exiting script."
                        exit 1
                    fi
                    ;;
                hostinfos)
                    hostinfos_only=true
                    ;;
                h)
                    show_help
                    ;;
                help)
                    show_help
                    ;;                    
                *)
                    echo "Invalid option: --$OPTARG" >&2
                    show_help
                    ;;
            esac
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            ;;
    esac
done

if [ -n "$archive_name" ]; then
    # Check if the file exists
    if [ -f "$archive_name" ]; then
        # Ask the user for confirmation
        if [ -n "$encryption_password" ]; then
            read -p "The file $archive_name exists. If you don't delete it, reports will be added/updated in current zip file with new password. Do you want to delete it? (y/n): " user_response
        else
            read -p "The file $archive_name exists. If you don't delete it, reports will be added/updated in current zip. Do you want to delete it? (y/n): " user_response
        fi
        if [ "$user_response" == "y" ]; then
            # Delete the file
            rm -f "$archive_name"
            echo "File deleted."
        else
            echo "File not deleted."
        fi
    else
        echo "The file $archive_name does not exist."
    fi
fi

perform_host_infos_and_archive "$archive_name" "$encryption_password"

if [ "$hostinfos_only" = false ]; then
    # If network_to_scan is empty, scan interfaces networks (except loopback)
    if [ -z "$network_to_scan" ]; then
        # Retrieve network interfaces
        interfaces=$(ip -o link show | awk -F': ' '{print $2}')

        echo 
        echo ------------------------------------------
        echo Found interfaces : $interfaces
        echo ------------------------------------------
        echo 

        # For each interface
        for interface in $interfaces; do
            # Get the IP and mask of interface
            ip_info=$(ip -4 -o addr show "$interface" | awk '{print $4}')

            # Check if the interface has an IP
            if [ ! -z "$ip_info" ]; then
                # Extract IP and mask from retrieved informations
                ip_address=$(echo "$ip_info" | awk -F'/' '{print $1}')
                subnet_mask=$(echo "$ip_info" | awk -F'/' '{print $2}')

                # Calculate network from IP and mask
                network=$(ipcalc -n -b "$ip_address/$subnet_mask" | grep "Network" | awk '{print $2}')

                # Exclude loopback network 
                if ! echo "$network" | grep -q "127.0.0.0"; then
                    perform_scan_and_archive "$network" "$use_vuln_script" "$archive_name" "$encryption_password" "$interface"
                else
                    echo "Excluding network $network (loopback)."
                fi
            fi
        done
    else
        perform_scan_and_archive "$network_to_scan" "$use_vuln_script" "$archive_name" "$encryption_password"
    fi
fi