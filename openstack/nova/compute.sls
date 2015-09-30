{% set serstart = salt['pillar.get']('virl:start_of_serial_port_range',salt['grains.get']('start_of_serial_port_range', '17000')) %}
{% set serend = salt['pillar.get']('virl:end_of_serial_port_range',salt['grains.get']('end_of_serial_port_range', '18000')) %}
{% set serial_port = salt['pillar.get']('virl:serial_port',salt['grains.get']('serial_port', '19406')) %}
{% set vnc_port = salt['pillar.get']('virl:vnc_port',salt['grains.get']('vnc_port', '19407')) %}
{% set controllerhname = salt['pillar.get']('virl:internalnet_controller_hostname',salt['grains.get']('internalnet_controller_hostname', 'controller')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set novapassword = salt['pillar.get']('virl:novapassword', salt['grains.get']('password', 'password')) %}
{% set rabbitpassword = salt['pillar.get']('virl:rabbitpassword', salt['grains.get']('password', 'password')) %}
{% set neutronpassword = salt['pillar.get']('virl:neutronpassword', salt['grains.get']('password', 'password')) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}

nova-common:
  pkg.installed:
    - order: 1
    - name: nova-compute
    - refresh: true

compute-pkgs:
  pkg.installed:
    - order: 2
    - refresh: False
    - names:
      - python-novaclient
      - nova-serialproxy


controller_hostname:
  host.present:
    - name: {{ controllerhname }}
    - ip: {{ controllerip }}

/etc/nova:
  file.directory:
    - dir_mode: 755

/etc/nova/nova.conf:
  file.managed:
    - mode: 755
    - source: "salt://files/nova.conf"

nova-conn:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'database'
    - parameter: 'connection'
    - value: ' mysql://keystone:{{ novapassword }}@{{ controllerip }}/nova'


nova-rabbitpass:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: 'rabbit_password = RABBIT_PASS'
    - repl: 'rabbit_password = {{ rabbitpassword }}'


nova-hostname:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: 'controller'
    - repl: '{{ controllerip }}'

nova-publicip:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: 'PUBLICIP'
    - repl: '{{ controllerip }}'

nova-verbose:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: 'verbose=True'
    - repl: 'verbose=False'

nova-password:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: 'NOVA_PASS'
    - repl: '{{ novapassword }}'

neut-password:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: 'NEUTRON_PASS'
    - repl: '{{ neutronpassword }}'

serial-start-stop:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: '17000:18000'
    - repl: '{{ serstart }}:{{ serend }}'


nova-compute-libvirt-serport:
  openstack_config.present:
    - filename: /etc/nova/nova-compute.conf
    - section: 'libvirt'
    - parameter: 'serial_port_range'
    - value: ' {{ serstart }}:{{ serend }}'

proxyclient-address:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'vncserver_proxyclient_address'
    - value: ' {{ controllerip }}'

vncserver_listen:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'vncserver_listen'
    - value: ' 0.0.0.0'

glance_host:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'glance_host'
    - value: ' {{ controllerip }}'

novncproxy_base:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'novncproxy_base_url'
    - value: ' http://{{ controllerip }}:{{ vnc_port }}/vnc_auto.html'

novncproxy_port:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'novncproxy_port'
    - value: ' {{ vnc_port }}'

{% if kilo %}
serialproxy_base:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'serial_console'
    - parameter: 'base_url'
    - value: ' http://{{ controllerip }}:{{ serial_port }}/serial.html'

serialproxy_port:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'serial_console'
    - parameter: 'serialproxy_port'
    - value: ' {{ serial_port }}'
{% else %}
serialproxy_base:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'serialproxy_base_url'
    - value: ' http://{{ controllerip }}:{{ serial_port }}/serial.html'

serialproxy_port:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'serialproxy_port'
    - value: ' {{ serial_port }}'
{% endif %}

/etc/init.d/nova-serialproxy:
  file.managed:
    - order: 4
    - source: "salt://files/nova-serialproxy"
    - mode: 0755

/etc/rc2.d/S98nova-serialproxy:
  file.symlink:
    - require:
      - file: /etc/init.d/nova-serialproxy
    - target: /etc/init.d/nova-serialproxy
    - mode: 0755

/usr/bin/kvm:
  file.managed:
    - order: 4
    - source: "salt://files/install_scripts/kvm"
    - mode: 0755

/usr/bin/kvm.real:
  file.symlink:
    - target: /usr/bin/qemu-system-x86_64
    - mode: 0755
    - require:
      - file: /usr/bin/kvm

/usr/local/bin/nova:
  file.symlink:
    - require:
      - pkg: nova-common
    - target: /usr/bin/nova
    - mode: 0755
