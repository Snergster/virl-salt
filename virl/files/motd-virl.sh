#!/bin/bash

mgmt=$(awk '$2 == 00000000 { print $1 }' /proc/net/route)
maddr=$(ip addr show dev $mgmt | awk '$1 == "inet" { sub("/..", "", $2); print $2}')
cat <<EOF
+*******************  Cisco VIRL Server  *******************+
|                                                           |
|    To manage your VIRL server please use the User         | 
|    Workspace Manager (UWM) web interface.                 |
|                                                           |
|    Point your browser to the URL shown below and use      |
|    the following default credentials:                     |
|                                                           |
|    User Name: uwmadmin                                    |
|    Password: password                                     |
|                                                           |
|    UWM URL:                                               |
|    http://$maddr                                          |
|                                                           |
+*******************  Cisco VIRL Server  *******************+
EOF
printf "\nDocumentation:  http://get.virl.info\n"
printf "Support:          https://learningnetwork.cisco.com/groups/virl\n"
printf "\nVIRL Server Interfaces: \n"

ifquery --list | egrep -v lo | sort | while read intf
do
ipadr=$(ip addr show dev $intf |awk '$1 == "inet" { sub("/..", "", $2); print $2}')
   ip link show $intf > /dev/null 2>&1
        if [ $? -ne 0 ] ; then
        printf ">>>>%sInterface $intf DOWN%s\n"
        else
        printf "%s    $intf: $ipadr\n"
        fi
done
echo ""