#!/bin/bash

SESSION_DIR=/var/local/virl/users/guest/endpoint/sessions

# get ip of interface with default route
# (usually eth0)
get_ip() {
    iface=$(ip route | awk '/^default / { for(i=0;i<NF;i++) { if ($i == "dev") { print $(i+1); next; }}}')
    echo $(ifconfig $iface | sed -rn 's/.*r:([^ ]+) .*/\1/p')
}


# we expect a single VIRL file (ignore jumphost)
session=$(ls -t1 $SESSION_DIR/*.virl | grep -v jumphost | head -1)

echo "http://"$(get_ip)":19402/?sim_id="$(basename "${session%.*}")"#/layer/phy"
exit 0
