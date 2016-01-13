#!/bin/bash
{% set l2_port = salt['pillar.get']('virl:l2_port', salt['grains.get']('l2_port', 'eth1' )) %}
{% set l2_port2 = salt['pillar.get']('virl:l2_port2', salt['grains.get']('l2_port2', 'eth2' )) %}
{% set l3_port = salt['pillar.get']('virl:l3_port', salt['grains.get']('l3_port', 'eth3' )) %}

{% macro loop(cmd) %}
    {% for eth in [ l2_port, l2_port2, l3_port ] %}
        ifquery --state {{ eth }} && {{ cmd }} {{ eth }}
    {% endfor %}
{% endmacro %}

if [ -z $version ] || [ $version == `uname -r` ]; then
    depmod
    {{ loop('ifdown') }}
    rmmod bridge
    {{ loop('ifup') }}
    modprobe bridge
    service neutron-plugin-linuxbridge-agent restart
    service neutron-dhcp-agent restart
    service neutron-l3-agent restart
else
    depmod $version
fi
