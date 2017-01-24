{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set domain = salt['pillar.get']('virl:domain_name', salt['grains.get']('domain_name', 'cisco.com')) %}
{% set public_ip = salt['pillar.get']('virl:static_ip', salt['grains.get']('static_ip', '127.0.0.1' )) %}
{% set neutronpassword = salt['pillar.get']('virl:neutronpassword', salt['grains.get']('password', 'password')) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set publicport = salt['pillar.get']('virl:public_port', salt['grains.get']('public_port', 'eth0')) %}
{% set dhcp = salt['pillar.get']('virl:using_dhcp_on_the_public_port', salt['grains.get']('using_dhcp_on_the_public_port', True )) %}
{% set public_gateway = salt['pillar.get']('virl:public_gateway', salt['grains.get']('public_gateway', '172.16.6.1' )) %}
{% set public_network = salt['pillar.get']('virl:public_network', salt['grains.get']('public_network', '172.16.6.0' )) %}
{% set public_netmask = salt['pillar.get']('virl:public_netmask', salt['grains.get']('public_netmask', '255.255.255.0' )) %}
{% set l2_port = salt['pillar.get']('virl:l2_port', salt['grains.get']('l2_port', 'eth1' )) %}
{% set l2_address = salt['pillar.get']('virl:l2_address', salt['grains.get']('l2_address', '172.16.1.254' )) %}
{% set l2_port2_enabled = salt['pillar.get']('virl:l2_port2_enabled', salt['grains.get']('l2_port2_enabled', 'True' )) %}
{% set l2_address2 = salt['pillar.get']('virl:l2_address2', salt['grains.get']('l2_address2', '172.16.2.254' )) %}
{% set l2_port2 = salt['pillar.get']('virl:l2_port2', salt['grains.get']('l2_port2', 'eth2' )) %}
{% set l3_address = salt['pillar.get']('virl:l3_address', salt['grains.get']('l3_address', '172.16.3.254/24' )) %}
{% set l3_port = salt['pillar.get']('virl:l3_port', salt['grains.get']('l3_port', 'eth3' )) %}
{% set fdns = salt['pillar.get']('virl:first_nameserver', salt['grains.get']('first_nameserver', '8.8.8.8' )) %}
{% set sdns = salt['pillar.get']('virl:second_nameserver', salt['grains.get']('second_nameserver', '8.8.4.4' )) %}
{% set int_ip = salt['pillar.get']('virl:internalnet_ip', salt['grains.get']('internalnet_ip', '172.16.10.250' )) %}
{% set int_gateway = salt['pillar.get']('virl:internalnet_gateway', salt['grains.get']('internalnet_gateway', '172.16.10.1' )) %}
{% set int_port = salt['pillar.get']('virl:internalnet_port', salt['grains.get']('internalnet_port', 'eth4' )) %}
{% set int_mask = salt['pillar.get']('virl:internalnet_netmask', salt['grains.get']('internalnet_netmask', '255.255.255.0' )) %}
{% set l3_mask = salt['pillar.get']('virl:l3_mask', salt['grains.get']('l3_mask', '255.255.255.0' )) %}
{% set l2_mask = salt['pillar.get']('virl:l2_mask', salt['grains.get']('l2_mask', '255.255.255.0' )) %}
{% set l2_mask2 = salt['pillar.get']('virl:l2_mask2', salt['grains.get']('l2_mask2', '255.255.255.0' )) %}
{% set dummy_int = salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', False )) %}
{% set jumbo_frames = salt['pillar.get']('virl:jumbo_frames', salt['grains.get']('jumbo_frames', False )) %}
{% set controller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True )) %}
{% set cluster = salt['pillar.get']('virl:virl_cluster', salt['grains.get']('virl_cluster', False )) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set ip = salt['cmd.run']("/usr/local/bin/getintip") %}
{% set compute1 = salt['grains.get']('compute1_internalnet_ip', '10.100.3.2' ) %}
{% set compute2 = salt['grains.get']('compute2_internalnet_ip', '10.100.3.3' ) %}
{% set compute3 = salt['grains.get']('compute3_internalnet_ip', '10.100.3.4' ) %}
{% set compute4 = salt['grains.get']('compute4_internalnet_ip', '10.100.3.5' ) %}
{% set compute1_active = salt['pillar.get']('virl:compute1_active', salt['grains.get']('compute1_active', True )) %}
{% set compute2_active = salt['pillar.get']('virl:compute2_active', salt['grains.get']('compute2_active', False )) %}
{% set compute3_active = salt['pillar.get']('virl:compute3_active', salt['grains.get']('compute3_active', False )) %}
{% set compute4_active = salt['pillar.get']('virl:compute4_active', salt['grains.get']('compute4_active', False )) %}
{% if salt['grains.get']('localhost', 'badlocalhost' ).startswith('compute1') %}
  {% set tunnelid = '1001' %}
  {% set udpport = '4201' %}
{% elif salt['grains.get']('localhost', 'badlocalhost' ).startswith('compute2') %}
  {% set tunnelid = '1002' %}
  {% set udpport = '4202' %}
{% elif salt['grains.get']('localhost', 'badlocalhost' ).startswith('compute3') %}
  {% set tunnelid = '1003' %}
  {% set udpport = '4203' %}
{% elif salt['grains.get']('localhost', 'badlocalhost' ).startswith('compute4') %}
  {% set tunnelid = '1004' %}
  {% set udpport = '4204' %}
{% else %}
  {% set tunnelid = '1010' %}
  {% set udpport = '4210' %}
{% endif %}

include:
  - virl.hostname
  - virl.hostname.packet
  {% if not 'xenial' in salt['grains.get']('oscodename') %}
  - virl.network.always_a_dummy
  {% endif %}

adding source to interfaces:
  cmd.run:
    - name: 'chattr -i /etc/network/interfaces'

/etc/network/interfaces.d/loop.cfg:
  file.managed:
    - contents:  |
          auto lo:1
          iface lo:1 inet loopback
              address 127.0.1.1
              netmask 255.0.0.0
  {% if not 'xenial' in salt['grains.get']('oscodename') %}
/etc/network/interfaces.d/flat.cfg:
  file.managed:
    - contents:  |
          auto {{l2_port}}
          iface {{l2_port}} inet static
              address {{l2_address}}
              netmask {{l2_mask}}
              post-up ip link set {{l2_port}} promisc on

/etc/network/interfaces.d/flat1.cfg:
  file.managed:
    - contents:  |
          auto {{l2_port2}}
          iface {{l2_port2}} inet static
              address {{l2_address2}}
              netmask {{l2_mask2}}
              post-up ip link set {{l2_port2}} promisc on

/etc/network/interfaces.d/snat.cfg:
  file.managed:
    - contents:  |
          auto {{l3_port}}
          iface {{l3_port}} inet static
              address {{l3_address}}
              netmask {{l3_mask}}
              post-up ip link set {{l3_port}} promisc on

remove dummy crud:
  file.absent:
    - name: /etc/network/interfaces.d/dummy.cfg

  {% else %}

/etc/network/interfaces.d/flat.cfg:
  file.managed:
    - contents:  |
          auto br1
          iface br1 inet static
              address {{l2_address}}
              netmask {{l2_mask}}
              bridge_maxwait 0
              bridge_ports {{l2_port}}
              bridge_stp off
              post-up ip link set br1 promisc on

/etc/network/interfaces.d/flat1.cfg:
  file.managed:
    - contents:  |
          auto br2
          iface br2 inet static
              address {{l2_address2}}
              netmask {{l2_mask2}}
              bridge_maxwait 0
              bridge_ports {{l2_port2}}
              bridge_stp off
              post-up ip link set br2 promisc on

/etc/network/interfaces.d/snat.cfg:
  file.managed:
    - contents:  |
          auto br1
          iface br1 inet static
              address {{l3_address}}
              netmask {{l3_mask}}
              bridge_maxwait 0
              bridge_ports {{l3_port}}
              bridge_stp off
              post-up ip link set br1 promisc on

remove dummy crud:
  file.absent:
    - name: /etc/network/interfaces.d/dummy.cfg
  {% endif %}

{% if not cluster %}

/etc/network/interfaces.d/internal.cfg:
  file.managed:
    - contents:  |
          auto {{int_port}}
          iface {{int_port}} inet static
              address {{int_ip}}
              netmask {{int_mask}}
              mtu 1500
              post-up ip link set {{int_port}} promisc on

remove cluster crud:
  file.absent:
    - name: /etc/network/interfaces.d/brl2tp.cfg

{% else %}
remove non cluster crud:
  file.absent:
    - name: /etc/network/interfaces.d/internal.cfg


  {% if controller %}

controller int in virl.ini:
  openstack_config.present:
    - filename: /etc/virl.ini
    - section: 'DEFAULT'
    - parameter: 'internalnet_controller_IP'
    - value: {{ip}}

tunnel controller side to compute:
  file.managed:
    - name: /etc/network/interfaces.d/brl2tp.cfg
    - contents:  |
          auto brl2tp
          iface brl2tp inet static
             address 172.16.9.10
             netmask 255.255.255.240
             bridge_ports tun1
             pre-up ip l2tp add tunnel remote {{compute1}} local {{ip}} tunnel_id 1001 peer_tunnel_id 1001 encap udp udp_sport 4201 udp_dport 4201 || true
             pre-up ip l2tp add session name tun1 tunnel_id 1001 session_id 1001 peer_session_id 1001 || true
             post-up ip link set dev tun1 master brl2tp up || true
             pre-down ip l2tp del session tunnel_id 1001 session_id 1001
             pre-down ip l2tp del tunnel tunnel_id 1001
            {%- if compute2_active %}
             pre-up ip l2tp add tunnel remote {{compute2}} local {{ip}} tunnel_id 1002 peer_tunnel_id 1002 encap udp udp_sport 4202 udp_dport 4202 || true
             pre-up ip l2tp add session name tun2 tunnel_id 1002 session_id 1002 peer_session_id 1002 || true
             post-up ip link set dev tun2 master brl2tp up || true
             pre-down ip l2tp del session tunnel_id 1002 session_id 1002
             pre-down ip l2tp del tunnel tunnel_id 1002
            {%- endif %}
            {%- if compute3_active %}
             pre-up ip l2tp add tunnel remote {{compute3}} local {{ip}} tunnel_id 1003 peer_tunnel_id 1003 encap udp udp_sport 4203 udp_dport 4203 || true
             pre-up ip l2tp add session name tun3 tunnel_id 1003 session_id 1003 peer_session_id 1003 || true
             post-up ip link set dev tun3 master brl2tp up || true
             pre-down ip l2tp del session tunnel_id 1003 session_id 1003
             pre-down ip l2tp del tunnel tunnel_id 1003
            {%- endif %}
            {%- if compute4_active %}
             pre-up ip l2tp add tunnel remote {{compute4}} local {{ip}} tunnel_id 1004 peer_tunnel_id 1004 encap udp udp_sport 4204 udp_dport 4204 || true
             pre-up ip l2tp add session name tun4 tunnel_id 1004 session_id 1004 peer_session_id 1004 || true
             post-up ip link set dev tun4 master brl2tp up || true
             pre-down ip l2tp del session tunnel_id 1004 session_id 1004
             pre-down ip l2tp del tunnel tunnel_id 1004
            {% endif %}

  {% else %}

tunnel compute side:
  file.managed:
    - name: /etc/network/interfaces.d/brl2tp.cfg
    - contents:  |
          auto brl2tp
          iface brl2tp inet static
             address {{ salt['pillar.get']('virl:neutron_local_ip', '172.16.9.5')}}
             netmask 255.255.255.240
             bridge_ports tun1
             pre-up ip l2tp add tunnel remote {{controllerip}} local {{int_ip}} tunnel_id {{ tunnelid }} peer_tunnel_id {{ tunnelid }} encap udp udp_sport {{udpport}} udp_dport {{udpport}} || true
             pre-up ip l2tp add session name tun1 tunnel_id {{ tunnelid }} session_id {{ tunnelid }} peer_session_id {{ tunnelid }} || true
             post-up ip link set dev tun1 master brl2tp up || true
             pre-down ip l2tp del session tunnel_id {{ tunnelid }} session_id {{ tunnelid }}
             pre-down ip l2tp del tunnel tunnel_id {{ tunnelid }}

  {% endif %}


{% endif %}

{% if cluster %}
compute restart for packet weirdness:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 003s"
    - marker_end: "# 003e"
    - content: |
             service nova-compute restart

marker for top of bond0:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: 'auto bond0:0'
    - repl: '#start of dead block'

marker for bottom of bond0::
  file.append:
    - name: /etc/network/interfaces
    - text: '#end of dead block'
    - unless: grep 'end of dead' /etc/network/interfaces

blank the mid:
  file.blockreplace:
    - name: /etc/network/interfaces
    - marker_start: '#start of dead block'
    - marker_end: '#end of dead block'
    - content: '#'

bond00 new:
  file.managed:
    - name: /etc/network/interfaces.d/bond00.cfg
    - contents:  |
          auto bond0:0
          iface bond0:0 inet manual
          up ip addr add {{ip}}/31 broadcast 255.255.255.255 dev bond0
          post-up route add -net 10.0.0.0/8 gw {{ int_gateway }}
          post-down route del -net 10.0.0.0/8 gw {{ int_gateway }}


{% endif %}

additional interfaces:
  file.append:
    - name: /etc/network/interfaces
    - text: source /etc/network/interfaces.d/*.cfg

  {% if 'xenial' in salt['grains.get']('oscodename') %}

br1 bringup:
  cmd.run:
    - unless: ifconfig br1
    - name: /sbin/ifup br1

br2 bringup:
  cmd.run:
    - unless: ifconfig br2
    - name: /sbin/ifup br2

br3 bringup:
  cmd.run:
    - unless: ifconfig br3
    - name: /sbin/ifup br3

br4 bringup:
  cmd.run:
    - unless: ifconfig br4
    - name: /sbin/ifup br4

  {% endif %}

get your dummy on:
  cmd.run:
    - names:
      - ifup {{l2_port}}
      - ifup {{l2_port2}}
      - ifup {{l3_port}}
{% if not cluster or not controller %}
      - ifup {{int_port}}
{% endif %}
