#!/bin/bash
#
# If using a bridged interface, some more stuff is required.
# The bridge will be attached to FLAT == l2_port interface.
# l2_port is defined in /etc/virl.ini
#
# First, get the L3 interface attached to FLAT.
# It might take a while until Neutron brings it up so we wait for it.
#
# 1 = tap_dev 
# 2 = tap_mtu
# 3 = link_mtu 
# 4 = ifconfig_local_ip 
# 5 = ifconfig_netmask 
# 6 = [ init | restart ]
#

{% set l2_port = salt['grains.get']('l2_port', 'eth1') %}
bridge_name=$(readlink -f "/sys/class/net/{{ l2_port }}/master")
[ -n "$bridge_name" ] || exit 1
bridge_name=$(basename "$bridge_name")

ip link set dev $1 master $bridge_name

# bring the VPN Tap device up
ifconfig $1 up mtu $2

# make sure that the bridge interfaces are not subject
# to iptables filtering
sysctl -w net.bridge.bridge-nf-call-iptables=0
sysctl -w net.bridge.bridge-nf-call-ip6tables=0

# add the bridge to iptables
# ufw allow in on $bridge_name

exit
