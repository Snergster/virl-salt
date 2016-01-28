#!/bin/bash
{% set l2_port = salt['pillar.get']('virl:l2_port', salt['grains.get']('l2_port', 'eth1' )) %}
{% set l2_port2 = salt['pillar.get']('virl:l2_port2', salt['grains.get']('l2_port2', 'eth2' )) %}
{% set l3_port = salt['pillar.get']('virl:l3_port', salt['grains.get']('l3_port', 'eth3' )) %}
{% set int_port = salt['pillar.get']('virl:internalnet_port', salt['grains.get']('internalnet_port', 'eth4' )) %}
{% set controller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True )) %}

{% macro loop(cmd) %}
    {% for eth in [ l2_port, l2_port2, l3_port, int_port ] %}
        ifquery --state {{ eth }} && {{ cmd }} {{ eth }}
    {% endfor %}
{% endmacro %}

{% macro loopup(cmd) %}
    {% for eth in [ l2_port, l2_port2, l3_port, int_port ] %}
        {{ cmd }} {{ eth }}
    {% endfor %}
{% endmacro %}


if [ -z $version ] || [ $version == `uname -r` ]; then
    depmod
    {{ loop('ifdown') }}
    rmmod bridge
    {{ loopup('ifup') }}
    modprobe bridge
    service neutron-plugin-linuxbridge-agent restart
{% if controller %}
    service neutron-dhcp-agent restart
    service neutron-l3-agent restart
{% endif %}

else
    depmod $version
fi
