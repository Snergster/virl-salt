{% set novapassword = salt['grains.get']('password', 'password') %}
{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set ks_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set serstart = salt['grains.get']('start_of_serial_port_range', '17000') %}
{% set serend = salt['grains.get']('end_of_serial_port_range', '18000') %}
{% set controllerhname = salt['grains.get']('internalnet_controller_hostname', 'controller') %}
{% set controllerip = salt['grains.get']('internalnet_controller_IP', '172.16.10.250') %}

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
    - file_mode: 755
    - source: "salt://files/nova.conf"

nova-conn:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: '#connection = <None>'
    - repl: 'connection = mysql://nova:{{ novapassword }}@{{ controllerip }}/nova'

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


nova-restart:
  cmd.run:
    - name: |
        su -s /bin/sh -c "nova-manage db sync" nova
        'dpkg-statoverride  --update --add root root 0644 /boot/vmlinuz-$(uname -r)'


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
    - value: ' http://{{ controllerip }}:6080/vnc_auto.html'



/etc/init.d/nova-serialproxy:
  file.managed:
    - order: 4
    - source: "salt://files/nova-serialproxy"
    - mode: 0755

/etc/rc2.d/S98nova-serialproxy:
  file.symlink:
    - order: 6
    - target: /etc/init.d/nova-serialproxy
    - mode: 0755

/usr/bin/kvm:
  file.managed:
    - order: 4
    - source: "salt://files/install_scripts/kvm"
    - mode: 0755

/usr/bin/kvm.real:
  file.symlink:
    - order: 6
    - target: /usr/bin/qemu-system-x86_64
    - mode: 0755

/usr/local/bin/nova:
  file.symlink:
    - order: 7
    - target: /usr/bin/nova
    - mode: 0755
