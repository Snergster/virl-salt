{% set public_ip = salt['pillar.get']('virl:static_ip', salt['grains.get']('static_ip', '127.0.0.1' )) %}
{% set serstart = salt['pillar.get']('virl:start_of_serial_port_range', salt['grains.get']('start_of_serial_port_range', '17000')) %}
{% set serend = salt['pillar.get']('virl:end_of_serial_port_range', salt['grains.get']('end_of_serial_port_range', '18000')) %}
{% set ramdisk = salt['pillar.get']('virl:ramdisk', salt['grains.get']('ramdisk', False)) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set rabbitpassword = salt['pillar.get']('virl:rabbitpassword', salt['grains.get']('password', 'password')) %}
{% set neutronpassword = salt['pillar.get']('virl:neutronpassword', salt['grains.get']('password', 'password')) %}
{% set novapassword = salt['pillar.get']('virl:novapassword', salt['grains.get']('password', 'password')) %}
{% set iscontroller = salt['pillar.get']('virl:iscontroller', salt['grains.get']('iscontroller', True)) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set controllerhostname = salt['pillar.get']('virl:internalnet_controller_hostname',salt['grains.get']('internalnet_controller_hostname', 'controller')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

include:
  - virl.ramdisk

nova-api:
  pkg.installed:
    - refresh: true

nova-pkgs:
  pkg.installed:
    - order: 2
    - refresh: False
    - require:
      - pkg: nova-api
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
    - template: jinja
    {% if masterless %}
    - source: "file:///srv/salt/openstack/nova/files/nova.conf"
    {% else %}
    - source: "salt://files/nova.conf.jinja"
    {% endif %}
    - require:
      - pkg: nova-pkgs

## if needs to go here for non controller
{% if iscontroller == False %}

nova-conn:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://nova:{{ mypassword }}@{{ controllerhostname }}/nova'
    - require:
      - file: /etc/nova/nova.conf

nova-hostname1:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'neutron_url'
    - value: 'http://{{ controllerhostname }}:9696'
    - require:
      - file: /etc/nova/nova.conf

nova-hostname2:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'neutron_admin_auth_url'
    - value: 'http://{{ controllerhostname }}:35357/v2.0'
    - require:
      - file: /etc/nova/nova.conf

nova-hostname3:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_host'
    - value: '{{ controllerhostname }}'
    - require:
      - file: /etc/nova/nova.conf

nova-hostname4:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_uri'
    - value: 'http://{{ controllerhostname }}:5000'
    - require:
      - file: /etc/nova/nova.conf

nova-hostname5:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_host'
    - value: '{{ controllerhostname }}'
    - require:
      - file: /etc/nova/nova.conf

{% endif %}

nova-restart:
  cmd.run:
    - onchanges:
      - pkg: nova-pkgs
      - file: /etc/nova/nova.conf
    - require:
      - pkg: nova-pkgs
      - file: /etc/nova/nova.conf
      - file: /etc/init.d/nova-serialproxy
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

/etc/init.d/nova-serialproxy:
  file.copy:
    - force: True
    - order: 4
    - source: /srv/salt/openstack/nova/files/nova-serialproxy
    - mode: 0755

/etc/rc2.d/S98nova-serialproxy:
  file.symlink:
    - order: 6
    - target: /etc/init.d/nova-serialproxy
    - mode: 0755
    - require:
      - file: /etc/init.d/nova-serialproxy

/usr/bin/kvm:
  file.copy:
    - force: True
    - order: 4
    - source: /srv/salt/openstack/nova/files/kvm
    - mode: 0755

/usr/bin/kvm.real:
  file.symlink:
    - order: 6
    - target: /usr/bin/qemu-system-x86_64
    - mode: 0755
    - require:
      - file: /usr/bin/kvm

/usr/local/bin/nova:
  file.symlink:
    - order: 7
    - target: /usr/bin/nova
    - mode: 0755
