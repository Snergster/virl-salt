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


eth0 ifdown:
  cmd.run:
    - name: ifdown {{virl.publicport}}

eth0:
  cmd.run:
{% if virl.dhcp %}
    - names:
      - 'salt-call --local ip.build_interface {{virl.publicport}} eth True proto=dhcp'
{% else %}
    - names:
      - 'salt-call --local ip.build_interface {{virl.publicport}} eth True proto=static dns-nameservers="{{virl.fdns}} {{virl.sdns}}" address={{virl.public_ip}} netmask={{virl.public_netmask}} gateway={{virl.public_gateway}}'
{% endif %}

set-dns-default:
  file.managed:
    - name: /etc/dhcp/dhclient.conf
    - source: 'salt://virl/files/dhclient.conf'
    - mode: 0644  

eth0 ifup:
  cmd.run:
    - name: ifup {{virl.publicport}}
    - require:
      - cmd: eth0