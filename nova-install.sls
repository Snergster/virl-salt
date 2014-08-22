{% set novapassword = salt['grains.get']('password', 'password') %}
{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set mypassword = salt['grains.get']('mysql_password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set ks_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set serstart = salt['grains.get']('start of serial port range', '17000') %}
{% set serend = salt['grains.get']('end of serial port range', '18000') %}

nova-api:
  pkg.installed:
    - order: 1
    - refresh: true

nova-pkgs:
  pkg.installed:
    - order: 2
    - refresh: False
    - names:
      - nova-cert
      - nova-conductor
      - nova-compute
      - python-guestfs
      - nova-consoleauth
      - nova-novncproxy
      - nova-scheduler
      - nova-serialproxy
      - python-novaclient

/etc/nova:
  file.directory:
    - dir_mode: 755

/etc/nova/nova.conf:
  file.managed:
    - file_mode: 755
    - source: "salt://virl/files/nova.conf"


nova-conn:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://nova:{{ mypassword }}@127.0.0.1/nova'

nova-rabbitpass:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: 'rabbit_password = RABBIT_PASS'
    - repl: 'rabbit_password = {{ rabbitpassword }}'


nova-hostname1:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'neutron_url'
    - value: 'http://{{ hostname }}:9696'

nova-hostname2:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'neutron_admin_auth_url'
    - value: 'http://{{ hostname }}:35357/v2.0'

nova-hostname3:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_host'
    - value: '{{ hostname }}'

nova-hostname4:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_uri'
    - value: 'http://{{ hostname }}:5000'

nova-hostname5:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_host'
    - value: '{{ hostname }}'

nova-publicip1:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'my_ip'
    - value: '{{ public_ip }}'

nova-publicip2:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'vncserver_listen'
    - value: '{{ public_ip }}'

nova-publicip3:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'vncserver_proxyclient_address'
    - value: '{{ public_ip }}'

neut-password:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'neutron_admin_password'
    - value: '{{ neutronpassword }}'

nova-password:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_password'
    - value: '{{ novapassword }}'

nova-verbose:
  file.replace:
    - name: /etc/nova/nova.conf
    - pattern: 'verbose=True'
    - repl: 'verbose=False'


nova-restart:
  cmd.run:
    - name: |
        su -s /bin/sh -c "glance-manage db_sync" glance
        su -s /bin/sh -c "nova-manage db sync" nova
        'dpkg-statoverride  --update --add root root 0644 /boot/vmlinuz-$(uname -r)'
        service nova-cert restart
        service nova-api restart
        service nova-consoleauth restart
        service nova-scheduler restart
        service nova-conductor restart
        service nova-novncproxy restart

nova-compute-libvirt-serport:
  openstack_config.present:
    - filename: /etc/nova/nova-compute.conf
    - section: 'libvirt'
    - parameter: 'serial_port_range'
    - value: ' {{ serstart }}:{{ serend }}'

/etc/init.d/nova-serialproxy:
  file.managed:
    - order: 4
    - source: "salt://virl/files/nova-serialproxy"
    - mode: 0755

/etc/rc2.d/S98nova-serialproxy:
  file.symlink:
    - order: 6
    - target: /etc/init.d/nova-serialproxy
    - mode: 0755

/usr/bin/kvm:
  file.managed:
    - order: 4
    - source: "salt://virl/files/install_scripts/kvm"
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
