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
{% set int_port = salt['pillar.get']('virl:internalnet_port', salt['grains.get']('internalnet_port', 'eth4' )) %}
{% set int_mask = salt['pillar.get']('virl:internalnet_netmask', salt['grains.get']('internalnet_netmask', '255.255.255.0' )) %}
{% set l3_mask = salt['pillar.get']('virl:l3_mask', salt['grains.get']('l3_mask', '255.255.255.0' )) %}
{% set l2_mask = salt['pillar.get']('virl:l2_mask', salt['grains.get']('l2_mask', '255.255.255.0' )) %}
{% set l2_mask2 = salt['pillar.get']('virl:l2_mask2', salt['grains.get']('l2_mask2', '255.255.255.0' )) %}
{% set dummy_int = salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', False )) %}
{% set jumbo_frames = salt['pillar.get']('virl:jumbo_frames', salt['grains.get']('jumbo_frames', False )) %}
{% set controller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True )) %}
{% set cluster = salt['pillar.get']('virl:virl_cluster', salt['grains.get']('virl_cluster', False )) %}
{% set ip = salt['cmd.run']("/usr/local/bin/getintip") %}

include:
  - virl.hostname

adding source to interfaces:
  cmd.run:
    - names: 
      - 'chattr -i /etc/network/interfaces'
  file.append:
    - name: /etc/network/interfaces
    - text: source /etc/network/interfaces.d/*.cfg

/etc/network/interfaces.d/dummy.cfg:
  file.managed:
    - contents:  |
          auto lo:1
          iface lo:1 inet loopback
              address 127.0.1.1
              netmask 255.0.0.0
          auto {{l2_port}}
          iface {{l2_port}} inet static
              address {{l2_address}}
              netmask {{l2_mask}}
              post-up ip link set {{l2_port}} promisc on
          auto {{l2_port2}}
          iface {{l2_port2}} inet static
              address {{l2_address2}}
              netmask {{l2_mask2}}
              post-up ip link set {{l2_port2}} promisc on
          auto {{l3_port}}
          iface {{l3_port}} inet static
              address {{l3_address}}
              netmask {{l3_mask}}
              post-up ip link set {{l3_port}} promisc on

{% if not cluster or not controller %}

/etc/network/interfaces.d/internal.cfg:
  file.managed:
    - contents:  |
          auto {{int_port}}
          iface {{int_port}} inet static
              address {{int_ip}}
              netmask {{int_mask}}
              mtu 1500
              post-up ip link set {{int_port}} promisc on

{% else %}
  {% if controller %}

controller int in virl.ini:
  openstack_config.present:
    - filename: /etc/virl.ini
    - section: 'DEFAULT'
    - parameter: 'internalnet_controller_IP'
    - value: {{ip}}
  {% endif %}

int in virl.ini:
  openstack_config.present:
    - filename: /etc/virl.ini
    - section: 'DEFAULT'
    - parameter: 'internalnet_IP'
    - value: {{ip}}

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
