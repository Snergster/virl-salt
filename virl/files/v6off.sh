{% set l2_port = salt['pillar.get']('virl:l2_port', salt['grains.get']('l2_port', 'eth1' )) %}
{% set l2_port2 = salt['pillar.get']('virl:l2_port2', salt['grains.get']('l2_port2', 'eth2' )) %}
{% set l3_port = salt['pillar.get']('virl:l3_port', salt['grains.get']('l3_port', 'eth3' )) %}

#!/bin/bash

IPV6_SYSCTL=/proc/sys/net/ipv6/conf

# these should reflect l2_port, l2_port2 and l3_port in virl.ini
MANUAL_NICS="{{l2_port}} {{l3_port}} {{l2_port2}}"

NICS=$(for i in $IPV6_SYSCTL/tap*; do echo $(basename $i); done)" $MANUAL_NICS"

for nic in $NICS; do
  echo $nic
  echo "1" >>$IPV6_SYSCTL/$nic/disable_ipv6
done

# disable IPv6 for new NICs (new taps)
echo "1" >>$IPV6_SYSCTL/default/disable_ipv6
