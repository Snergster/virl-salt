{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set domain = salt['grains.get']('domain', 'cisco.com') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set publicport = salt['grains.get']('public_port', 'eth0') %}
{% set dhcp = salt['grains.get']('using_dhcp_on_the_public_port', True ) %}
{% set public_ip = salt['grains.get']('static_ip', '127.0.0.1' ) %}
{% set public_gateway = salt['grains.get']('public_gateway', '172.16.6.1' ) %}
{% set public_netmask = salt['grains.get']('public_netmask', '255.255.255.0' ) %}
{% set l2_port = salt['grains.get']('l2_port', 'eth1' ) %}
{% set l2_address = salt['grains.get']('l2_address', '172.16.1.254' ) %}
{% set l2_address2 = salt['grains.get']('l2_address2', '172.16.2.254' ) %}
{% set l3_address = salt['grains.get']('l3_address', '172.16.3.254' ) %}
{% set l2_port2 = salt['grains.get']('l2_port2', 'eth2' ) %}
{% set l2_port2_enabled = salt['grains.get']('l2_port2_enabled', 'True' ) %}
{% set l3_port = salt['grains.get']('l3_port', 'eth3' ) %}
{% set fdns = salt['grains.get']('first_nameserver', '8.8.8.8' ) %}
{% set sdns = salt['grains.get']('second_nameserver', '8.8.4.4' ) %}
{% set int_ip = salt['grains.get']('internalnet_ip', '172.16.10.250' ) %}
{% set int_port = salt['grains.get']('internalnet_port', 'eth4' ) %}
{% set int_mask = salt['grains.get']('internalnet_netmask', '255.255.255.0' ) %}
{% set l3_mask = salt['grains.get']('l3_mask', '255.255.255.0' ) %}
{% set l2_mask2 = salt['grains.get']('l2_mask2', '255.255.255.0' ) %}
{% set l2_mask = salt['grains.get']('l2_mask', '255.255.255.0' ) %}
{% set dummy_int = salt['grains.get']('dummy_int', False ) %}
{% set jumbo_frames = salt['grains.get']('jumbo_frames', False ) %}

blank what is there:
  file.absent:
    - order: 1
    - name: /etc/network/interfaces


{% if dummy_int == True %}
dummy modprobe:
  file.append:
    - name: /etc/modules
    - text: dummy numdummies=5

{% endif %}

system:
  network.system:
    - enabled: False
    - hostname: {{hostname}}.{{domain}}
    - gatewaydev: {{ publicport }}

eth0:
  network.managed:
    - order: 2
    - name: {{ publicport }}
    - enabled: True
    - type: eth
{% if dhcp == True %}
    - proto: dhcp
{% else %}
    - proto: static
    - ipaddr: {{ public_ip }}
    - netmask: {{ public_netmask }}
    - gateway: {{ public_gateway }}
    - dns:
      - {{ fdns }}
      - {{ sdns }}
{% endif %}


{{ int_port }}:
  network.managed:
    - ipaddr: {{ int_ip }}
    - proto: static
    - netmask: {{ int_mask }}
    - type: eth
    - enabled: True
{% if jumbo_frames == True %}
    - mtu: 9100
{% else %}
    - mtu: 1550
{% endif %}

loop0:
  network.managed:
    - order: 2
    - enabled: True
    - name: 'lo'
    - type: eth
    - enabled: True
    - proto: loopback

loop1:
  network.managed:
    - order: 2
    - enabled: True
    - name: 'lo:1'
    - ipaddr: 127.0.1.1
    - netmask: 255.255.255.0
    - type: eth
    - enabled: True
    - proto: loopback

{{ l2_port }}:
  network.managed:
    - order: 2
    - enabled: True
    - proto: manual
    - type: eth
    - ipaddr: {{ l2_address }}
    - netmask: {{ l2_mask }}


{% if l2_port2_enabled == True %}
{{ l2_port2 }}:
  network.managed:
    - order: 2
    - enabled: True
    - proto: manual
    - type: eth
    - ipaddr: {{ l2_address2 }}
    - netmask: {{ l2_mask2 }}


man-flat2-address:
  file.replace:
    - order: 3
    - name: /etc/network/interfaces
    - pattern: {{ l2_address2 }}
    - repl: '{{ l2_address2 }}\n    up ip link set {{l2_port2}} promisc on'
    - require:
      - network: {{ l2_port2 }}

{% endif %}

{{ l3_port }}:
  network.managed:
    - order: 2
    - name: {{ l3_port }}
    - enabled: True
    - proto: manual
    - type: eth
    - ipaddr: {{ l3_address }}
    - netmask: {{ l3_mask }}


man-flat-promisc:
  file.replace:
    - order: 3
    - name: /etc/network/interfaces
    - pattern: {{ l2_address }}
    - repl: '{{ l2_address }}\n    up ip link set {{l2_port}} promisc on'
    - require:
      - network: {{ l2_port }}

man-snat-promisc:
  file.replace:
    - order: 3
    - name: /etc/network/interfaces
    - pattern: {{ l3_address }}
    - repl: '{{ l3_address }}\n    up ip link set {{l3_port}} promisc on'
    - require:
      - network: {{ l3_port }}

man-int-promisc:
  file.replace:
    - order: 3
    - name: /etc/network/interfaces
    - pattern: {{ int_ip }}
    - repl: '{{ int_ip }}\n    up ip link set {{int_port}} promisc on'
    - require:
      - network: {{ int_port }}



vhost:
  host.present:
    - name: {{ hostname }}.{{domain}}
    - ip: {{ public_ip }}

vhostloop:
  host.present:
    - name: {{ hostname }}
    - ip: 127.0.1.1

vhostname:
  file.managed:
    - name: /etc/hostname
    - contents: {{ hostname }}

/etc/init/failsafe.conf:
  file.managed:
    - file_mode: 644
    - source: "salt://files/failsafe.conf"

    
