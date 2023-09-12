#!/bin/bash

# Function to retrieve host infos and archive
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
    echo ------------------------------------------
    echo 

    sudo rm -f "$host_infos_file"

     
    echo ------------------------------------------ >> $host_infos_file
    echo uname -a >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    uname -a >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo ip addr >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    ip addr >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo hciconfig >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    hciconfig >> $host_infos_file 

    echo ------------------------------------------ >> $host_infos_file
    echo hcitool scan >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    hcitool scan >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo iwconfig >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    iwconfig >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo wlan0 scan >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    iwlist wlan0 scan >> $host_infos_file

    echo ------------------------------------------ >> $host_infos_file
    echo sudo iwlist scan >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    sudo iwlist scan >> $host_infos_file
    
    echo ------------------------------------------ >> $host_infos_file
    echo mtr -r -c 1  8.8.8.8 >> $host_infos_file
    echo ------------------------------------------ >> $host_infos_file
    mtr -r -c 1  8.8.8.8  >> $host_infos_file

    # Create archive and encrypt if password is provided
    if [ -n "$archive_name" ]; then
        echo 
        echo ------------------------------------------
        echo "Creating archive $archive_name..."
        
        if [ -n "$encryption_password" ]; then
            
            # Ajoutez les fichiers à l'archive 
            sudo zip -q -r --password "$encryption_password" "$archive_name" "$host_infos_file"
            

        else
            # Créez l'archive ZIP sans chiffrement
            sudo zip -q -r "$archive_name" "$host_infos_file"
        fi

        # Vérifiez si la création de l'archive a réussi
        if [ $? -eq 0 ]; then
            echo "Zip $archive_name created."
            echo ------------------------------------------
            echo

            # Supprimez les fichiers d'origine
            sudo rm -f "$host_infos_file"
        else
            echo "Failed to create zip $archive_name."
        fi
    fi

    echo 
    echo ------------------------------------------
    echo
    echo END OF RETRIEVING HOST INFORMATIONS
    echo
    echo ------------------------------------------
    echo 

}

# Function to execute Nmap, transform report to HTML, make an archive and crypt the archive
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
    echo Zip Name :       $archive_name
    if [ -n "$encryption_password" ]; then echo Zip Password : yes
        else echo Zip Password : no
    fi
    echo netdiscover_file : $netdiscover_file
    echo ------------------------------------------
    echo 

    sudo rm -f "$netdiscover_file"

    if [ -n "$interface" ]; then
        echo ------------------------------------------ >> $netdiscover_file
        echo "sudo netdiscover -i $interface -r $network -P " >> $netdiscover_file
        echo ------------------------------------------ >> $netdiscover_file
        sudo netdiscover -i $interface -r $network -P  >> $netdiscover_file
    else
        echo ------------------------------------------ >> $netdiscover_file
        echo "sudo netdiscover -r $network -P " >> $netdiscover_file
        echo ------------------------------------------ >> $netdiscover_file
        sudo netdiscover -r $network -P  >> $netdiscover_file
    fi
    
    perform_nmap_scan "$network" "$output_file" "$use_vuln_script"
    generate_html_report "$output_file" "$output_file_html"

        # Create archive and encrypt if password is provided
    if [ -n "$archive_name" ]; then
        echo 
        echo ------------------------------------------
        echo "Creating archive $archive_name..."
        
        if [ -n "$encryption_password" ]; then
            # Créez un fichier temporaire pour stocker les fichiers à archiver

            
            # Ajoutez les fichiers à l'archive temporaire
            sudo zip -q -r --password "$encryption_password" "$archive_name" "$output_file" "$output_file_html" "$netdiscover_file"

        else
            # Créez l'archive ZIP sans chiffrement
            sudo zip -q -r "$archive_name" "$output_file" "$output_file_html" "$netdiscover_file"
        fi

        # Vérifiez si la création de l'archive a réussi
        if [ $? -eq 0 ]; then
            echo "Zip $archive_name created."
            echo ------------------------------------------
            echo

            # Supprimez les fichiers d'origine
            sudo rm -f "$output_file" "$output_file_html" "$netdiscover_file"
        else
            echo "Failed to create zip $archive_name."
        fi
    fi

    echo 
    echo ------------------------------------------
    echo
    echo END OF RETRIEVING NETWORK INFORMATIONS
    echo
    echo ------------------------------------------
    echo


}

# Fonction pour ex�cuter la num�risation Nmap
perform_nmap_scan() {
    local network="$1"
    local output_file="$2"
    local use_vuln_script="$3"

    echo 
    echo ------------------------------------------
    if [ "$use_vuln_script" = true ]; then
        echo "Scanning network $network with vuln scripts..."
        sudo nmap -sV -sC --script vuln "$network" -oX "$output_file"
    else
        echo "Scanning network $network..."
        sudo nmap -sV -sC "$network" -oX "$output_file"
    fi
    echo ------------------------------------------
    echo

    echo 
    echo ------------------------------------------
    echo "Scan of $network completed. Results saved in $output_file"
    echo ------------------------------------------
    echo
}

# Function to make html report from XML report
generate_html_report() {
    local xml_file="$1"
    local html_file="$2"

    echo "Making html report from xml result..."
    sudo xsltproc "$xml_file" -o "$html_file"

    echo 
    echo ------------------------------------------
    echo "HTML report saved in $html_file"
    echo ------------------------------------------
    echo 
}

# Function to encryp results 
encrypt_file() {
    local input_file="$1"
    local output_file="$2"
    local password="$3"

    echo 
    echo ------------------------------------------
    echo "Encrypting $input_file..."
    echo ------------------------------------------
    echo 
    
    sudo openssl enc -aes-256-cbc -salt -in "$input_file" -out "$output_file" -pass pass:"$password"
}

# Function to display helpe
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

# Analyser les options de ligne de commande
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
                    echo "Option non reconnue: --$OPTARG" >&2
                    show_help
                    ;;
            esac
            ;;
        \?)
            echo "Option invalide: -$OPTARG" >&2
            show_help
            ;;
    esac
done

perform_host_infos_and_archive "$archive_name" "$encryption_password"

if [ "$hostinfos_only" = false ]; then
    # Si network_to_scan est vide, scanner les r�seaux des interfaces d�tect�es
    if [ -z "$network_to_scan" ]; then
        # Obtenir la liste des interfaces r�seau
        interfaces=$(ip -o link show | awk -F': ' '{print $2}')

        echo 
        echo ------------------------------------------
        echo Found interfaces : $interfaces
        echo ------------------------------------------
        echo 

        # Parcourir chaque interface r�seau
        for interface in $interfaces; do
            # Obtenir l'adresse IP et le masque de l'interface
            ip_info=$(ip -4 -o addr show "$interface" | awk '{print $4}')

            # V�rifier que l'interface a une adresse IP (�vite les interfaces non connect�es)
            if [ ! -z "$ip_info" ]; then
                # Extraire l'adresse IP et le masque de l'information obtenue
                ip_address=$(echo "$ip_info" | awk -F'/' '{print $1}')
                subnet_mask=$(echo "$ip_info" | awk -F'/' '{print $2}')

                # Calculer le r�seau en fonction de l'adresse IP et du masque
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