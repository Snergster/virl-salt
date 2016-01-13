{% set serstart = salt['pillar.get']('virl:start_of_serial_port_range',salt['grains.get']('start_of_serial_port_range', '17000')) %}
{% set serend = salt['pillar.get']('virl:end_of_serial_port_range',salt['grains.get']('end_of_serial_port_range', '18000')) %}
{% set serial_port = salt['pillar.get']('virl:serial_port',salt['grains.get']('serial_port', '19406')) %}
{% set vnc_port = salt['pillar.get']('virl:vnc_port',salt['grains.get']('vnc_port', '19407')) %}
{% set controllerhname = salt['pillar.get']('virl:internalnet_controller_hostname',salt['grains.get']('internalnet_controller_hostname', 'controller')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set novapassword = salt['pillar.get']('virl:novapassword', salt['grains.get']('password', 'password')) %}
{% set rabbitpassword = salt['pillar.get']('virl:rabbitpassword', salt['grains.get']('password', 'password')) %}
{% set neutronpassword = salt['pillar.get']('virl:neutronpassword', salt['grains.get']('password', 'password')) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', True)) %}


compute-pkgs:
  pkg.installed:
    - refresh: True
    - names:
      - nova-compute
      - python-novaclient
      - nova-serialproxy

/etc/nova/nova.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://openstack/nova/files/kilo.nova.conf"
    - require:
      - pkg: compute-pkgs

add libvirt-qemu to nova:
  group.present:
    - name: nova
    - delusers:
      - libvirt-qemu


controller_hostname:
  host.present:
    - name: {{ controllerhname }}
    - ip: {{ controllerip }}


