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
  - common.kvm

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
    - source: "salt://openstack/nova/files/nova.conf"
    {% endif %}
    - require:
      - pkg: nova-pkgs


/srv/salt/openstack/nova/patch/driver.diff:
  file.managed:
    - makedirs: True
    - file_mode: 755
    - contents: |
        --- driver.py	2014-07-10 13:22:21.000000000 +0000
        +++ driver.py	2015-02-10 22:26:30.465829748 +0000
        @@ -56,7 +56,6 @@
         from eventlet import greenthread
         from eventlet import patcher
         from eventlet import tpool
        -from eventlet import util as eventlet_util
         from lxml import etree
         from oslo.config import cfg

        @@ -622,12 +621,10 @@
                 except (ImportError, NotImplementedError):
                     # This is Windows compatibility -- use a socket instead
                     #  of a pipe because pipes don't really exist on Windows.
        -            sock = eventlet_util.__original_socket__(socket.AF_INET,
        -                                                     socket.SOCK_STREAM)
        +            sock = native_socket.socket(socket.AF_INET,socket.SOCK_STREAM)
                     sock.bind(('localhost', 0))
                     sock.listen(50)
        -            csock = eventlet_util.__original_socket__(socket.AF_INET,
        -                                                      socket.SOCK_STREAM)
        +            csock = native_socket.socket(socket.AF_INET,socket.SOCK_STREAM)
                     csock.connect(('localhost', sock.getsockname()[1]))
                     nsock, addr = sock.accept()
                     self._event_notify_send = nsock.makefile('wb', 0)

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py:
  file.patch:
    - source: file:///srv/salt/openstack/nova/patch/driver.diff
    - hash: md5=7163850e833c811470fc1f2d46fbb5ea
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virl/libvirt/driver.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py
    - require:
      - file: /srv/salt/openstack/nova/patch/driver.diff
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

nova-compute serial:
  openstack_config.present:
    - filename: /etc/nova/nova-compute.conf
    - section: 'libvirt'
    - parameter: 'serial_port_range'
    - value: '{{ serstart }}:{{ serend }}'

nova-restart:
  cmd.run:
    - order: last
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
        service nova-compute restart
        service nova-novncproxy restart

/etc/init.d/nova-serialproxy:
  {% if masterless %}
  file.copy:
    - source: /srv/salt/openstack/nova/files/nova-serialproxy
  {% else %}
  file.managed:
    - source: "salt://openstack/nova/files/nova-serialproxy"
  {% endif %}
    - force: True
    - order: 4
    - mode: 0755

/etc/rc2.d/S98nova-serialproxy:
  file.absent


/home/virl/.novaclient:
  file.directory:
    - user: virl
    - group: virl
    - recurse:
      - user
      - group
      
