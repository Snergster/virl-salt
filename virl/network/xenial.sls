{% from "virl.jinja" import virl with context %}

blank what is there:
  cmd.run:
    - name: "mv /etc/network/interfaces /etc/network/interfaces.bak.$(date +'%Y%m%d_%H%M%S')"
    - onlyif: test -e /etc/network/interfaces

system:
  network.system:
    - enabled: False
    - hostname: {{virl.hostname}}.{{virl.domain_name}}
    - gatewaydev: {{ virl.publicport }}



br4 interface:
  cmd.run:
    - name: 'salt-call --local ip.build_interface br4 bridge True address={{ virl.int_ip }} proto=static netmask={{ virl.int_mask }} mtu=1500 ports={{ virl.int_port }}'


loop0:
  network.managed:
    - enabled: True
    - name: 'lo'
    - type: eth
    - enabled: True
    - proto: loopback


loop1:
  cmd.run:
    - name: 'salt-call --local ip.build_interface "lo:1" eth True address=127.0.1.1 proto=loopback netmask=255.0.0.0'



br1 interface:
  network.managed:
    - name: br1
    - enabled: True
    - proto: static
    - type: bridge
    - ipaddr: {{ virl.l2_address }}
    - netmask: {{ virl.l2_mask }}
    - ports: {{ virl.l2_port }}

man-flat-promisc:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: {{ virl.l2_address }}
    - repl: '{{ virl.l2_address }}\n    post-up ip link set br1 promisc on'
    - require:
      - network: br1 interface


{% if virl.l2_port2_enabled %}
br2 interface:
  network.managed:
    - name: br2
    - enabled: True
    - proto: static
    - type: bridge
    - ipaddr: {{ virl.l2_address2 }}
    - netmask: {{ virl.l2_mask2 }}
    - ports: {{ virl.l2_port2 }}


man-flat2-address:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: {{ virl.l2_address2 }}
    - repl: '{{ virl.l2_address2 }}\n    post-up ip link set br2 promisc on'
    - require:
      - network: br2 interface

{% endif %}

br3 interface:
  network.managed:
    - name: br3
    - enabled: True
    - proto: static
    - type: bridge
    - ipaddr: {{ virl.l3_address }}
    - netmask: {{ virl.l3_mask }}
    - ports: {{ virl.l3_port }}

man-snat-promisc:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: {{ virl.l3_address }}
    - repl: '{{ virl.l3_address }}\n    post-up ip link set {{virl.l3_port}} promisc on'
    - require:
      - network: br3 interface

man-int-promisc:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: {{ virl.int_ip }}
    - repl: '{{ virl.int_ip }}\n    post-up ip link set {{ virl.int_port }} promisc on'
    - require:
      - cmd: br4 interface
  cmd.run:
    - name: ifup br4

eth0 ifdown:
  cmd.run:
    - name: ifdown {{virl.publicport}}

eth0:
  cmd.run:
{% if virl.dhcp %}
    - names:
      - 'salt-call --local ip.build_interface {{virl.publicport}} eth True proto=dhcp dns-nameservers="{{virl.fdns}} {{virl.sdns}}"'
{% else %}
    - names:
      - 'salt-call --local ip.build_interface {{virl.publicport}} eth True proto=static dns-nameservers="{{virl.fdns}} {{virl.sdns}}" address={{virl.public_ip}} netmask={{virl.public_netmask}} gateway={{virl.public_gateway}}'
{% endif %}


eth0 ifup:
  cmd.run:
    - name: ifup {{virl.publicport}}
    - require:
      - cmd: eth0