#!/bin/bash
depmod
rmmod bridge
modprobe bridge
service neutron-plugin-linuxbridge-agent restart
service neutron-dhcp-agent restart
service neutron-l3-agent restart
