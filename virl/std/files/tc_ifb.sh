#!/bin/bash

## Utility to handle ifb iface assignment to tap ifaces.
## Used by traffic control API
## This, once called, should pick an available ifb iface, rename it
## so it matches the tap iface naming convention and set the forwarding
## between the two. Also, cleanup.

#set -e


usage() {
	echo "Usage: ./tc-ifb.sh (create|clean) <tap iface suffix>"
	exit 0
}

if [[ "$#" -lt 1 ]];then
        usage
fi;

if [ `id -u` -ne 0 ]; then
   echo "You need root privileges to run this script"
   exit 1
fi

create() {
	ifbface=$(ip link show | grep -o -P -m1 'ifb[^:]+(?=.*state DOWN)')
	if [[ -z $ifbface ]]; then
		echo "Out of ifb interfaces, aborting."
		exit 1
	fi
	echo "Proceeding with $ifbface"
	ifb_new_name="ifb$1"
	ip link set dev $ifbface name $ifb_new_name
	ip link set dev $ifb_new_name up
	echo "Created IFB iface \"$ifb_new_name\""
	tc qdisc add dev "tap$1" ingress
	tc filter add dev "tap$1" parent ffff: protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress redirect dev "$ifb_new_name"
	exit 0
}

cleanup() {
	ifbface=$(ip link show | grep -o -P -m1 "ifb$1")
        if [[ -z $ifbface ]]; then
                echo "Ifb interface not found, aborting."
                exit 0
        fi
        echo "Proceeding with $ifbface"
	tc qdisc del dev "ifb$1" root
	tc qdisc del dev "tap$1" parent ffff:fff1
	ip link set dev "$ifbface" down
	echo "Interface \"$ifbface\" set to down."
}

if [[ "$1" = "create" ]];then
	create $2
	exit 0
fi
if [[ "$1" = "clean" ]];then
	cleanup $2
	exit 0
fi
usage
