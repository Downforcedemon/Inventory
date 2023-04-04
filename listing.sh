#!/bin/bash
# declare global variable
declare -g domain_server="server1.com"

#fuction to retrieve data from domain server
function get_domain_data(){
    #use global variable in function
    echo"Retrieving data from domain server $domain_server...."
    
}
function get_ad_user_groups() {
    # Use global variables for Active Directory settings
    local ad_server=$ad_server
    local ad_port=$ad_port
    local ad_basedn=$ad_basedn
    local ad_binddn=$ad_binddn
    local ad_bindpw=$ad_bindpw
    
    # Set LDAP search filter for user accounts
    local filter="(&(objectClass=user)(sAMAccountName=*))"

    # Run LDAP search to retrieve user accounts
    local users=$(ldapsearch -x -H ldap://$ad_server:$ad_port -D "$ad_binddn" -w "$ad_bindpw" -b "$ad_basedn" "$filter" | grep sAMAccountName | awk '{print $2}')

    # Loop through list of user names
    for user in $users; do
        # Run LDAP search to retrieve group membership for user
        local groups=$(ldapsearch -x -H ldap://$ad_server:$ad_port -D "$ad_binddn" -w "$ad_bindpw" -b "$ad_basedn" "(&(objectClass=user)(sAMAccountName=$user))" memberOf | grep memberOf | awk '{print $2}')

        # Print user name and groups
        echo "User: $user"
        echo "Groups: $groups"
        echo
    done
}
#get desktops
function get_domain_computers {
    local filter="(&(objectClass=computer)(objectCategory=computer))"
    local computers=$(ldapsearch -x -H ldap://$ad_server;$ad_port -D "$ad_bindpw" -b "$ad_basdn" "$filter" | grep "sAMAccountName" | awk '{print $2}')
    echo "$computers"

}  
# nmap them for ip's and arp them for mac's 
function scan_domain_computers {
    local computers=$(get_domain_computers)
    local ips=()

    for computer in $computers;do
    #perfom nmap
    local ip=$(nmap -sP -Pn $computer | grep -oP '(?<=for )[^\)]+')

    #append ip's to array
    ips+=("$ip")
    done

    #use arp for mac
    for ip in "${ip[@]}"; do
       local mac=$(arp -n $ip | awk '/:/ {print $3}')
       echo "$ip = $mac"
    done 

}
# 



































