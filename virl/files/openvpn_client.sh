#!/bin/bash
#
# This installs OpenVPN plus certificates.
# Resulting client config files in CFG_VPN_CONF from config
# 
# Copied from Ralph Schmieder, CISCO
# Use Jinja template
#
#set -x

{% set openvpn_dir = '/etc/openvpn' %}
{% set client_name = 'client' %}
{% set openvpn_dev = 'tap0' %}
{% set openvpn_ovpn_path = '/var/local/virl/client.ovpn' %}

{% set public_port = salt['grains.get']('public_port', 'eth0') %}
{% set openvpn_tcp = salt['grains.get']('openvpn_tcp', True) %}
{% set openvpn_tcp_number = salt['grains.get']('openvpn_tcp_number', '443') %}
{% set openvpn_udp_number = salt['grains.get']('openvpn_udp_number', '1194') %}

{% if openvpn_tcp %}
  {% set openvpn_port = openvpn_tcp_number %}
  {% set openvpn_proto = 'tcp' %}
{% else %}
  {% set openvpn_port = openvpn_udp_number %}
  {% set openvpn_proto = 'udp' %}
{% endif %}
#
# client config file
#
#this is crude mechanic to ensure openvpn_ovpn_path exists
/bin/mkdir -p /var/local/virl
#end crude hack
cat >{{ openvpn_ovpn_path }} <<EOF
#  VIRL OpenVPN Client Configuration
client
dev {{ openvpn_dev }}
port {{ openvpn_port }}
proto {{ openvpn_proto }}
persist-tun
verb 2
mute 3
nobind
reneg-sec 604800
# sndbuf 100000
# rcvbuf 100000

# Verify server certificate by checking
# that the certicate has the nsCertType
# field set to "server".  This is an
# important precaution to protect against
# a potential attack discussed here:
#  http://openvpn.net/howto.html#mitm
#
# To use this feature, you will need to generate
# your server certificates with the nsCertType
# field set to "server".  The build-key-server
# script in the easy-rsa folder will do this.
ns-cert-type server

# If you are connecting through an
# HTTP proxy to reach the actual OpenVPN
# server, put the proxy server/IP and
# port number here.  See the man page
# if your proxy server requires
# authentication.
;http-proxy-retry # retry on connection failures
;http-proxy [proxy server] [proxy port #]

remote $(ip -f inet addr show {{ public_port }} | sed -n '/inet/{s,.*inet \([0-9.]*\)/.*,\1,p;q}')

<ca>
$(sed -n '/^-----BEGIN/,/^-----END/p' "{{ openvpn_dir }}/ca.crt")
</ca>
<cert>
$(sed -n '/^-----BEGIN/,/^-----END/p' "{{ openvpn_dir }}/{{ client_name }}.crt")
</cert>
<key>
$(sed -n '/^-----BEGIN/,/^-----END/p' "{{ openvpn_dir }}/{{ client_name }}.key")
</key>
EOF
