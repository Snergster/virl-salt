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
{% set internalnetip = salt['pillar.get']('virl:internalnet_ip',salt['grains.get']('internalnet_ip', '172.16.10.250')) %}
{% set cluster = salt['pillar.get']('virl:virl_cluster', salt['grains.get']('virl_cluster', False )) %}


compute-pkgs:
  pkg.installed:
    - refresh: True
    - names:
      - nova-compute
      - python-novaclient
      - nova-serialproxy

/etc/nova permissions check:
  file.directory:
    - dir_mode: 755

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

serial_console tune:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'serial_console'
    - parameter: 'proxyclient_address'
    - value: {{ internalnetip }}
    - require:
      - file: /etc/nova/nova.conf

serial_console tune2:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'serial_console'
    - parameter: 'serial_port_proxyclient_address'
    - value: {{ internalnetip }}
    - require:
      - file: /etc/nova/nova.conf

glance tune:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'glance'
    - parameter: 'host'
    - value: {{ controllerip }}
    - require:
      - file: /etc/nova/nova.conf

vncserver tune:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'vncserver_listen'
    - value: '0.0.0.0'
    - require:
      - file: /etc/nova/nova.conf

vncserver tune2:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'vncserver_proxyclient_address'
    - value: {{ internalnetip }}
    - require:
      - file: /etc/nova/nova.conf


/usr/lib/python2.7/dist-packages/nova/cmd/serialproxy.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/serialproxy.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/cmd/serialproxy.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/cmd/serialproxy.py

/usr/lib/python2.7/dist-packages/nova/cmd/baseproxy.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/baseproxy.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/cmd/baseproxy.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/cmd/baseproxy.py


/usr/lib/python2.7/dist-packages/nova/api/openstack/compute/contrib/consoles.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/consoles.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/contrib/consoles.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/contrib/consoles.py

/usr/lib/python2.7/dist-packages/nova/api/openstack/compute/plugins/v3/remote_consoles.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/plugin.remote_consoles.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/plugins/v3/remote_consoles.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/plugins/v3/remote_consoles.py

/usr/lib/python2.7/dist-packages/nova/api/openstack/compute/schemas/v3/remote_consoles.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/schemas.remote_consoles.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/schemas/v3/remote_consoles.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/schemas/v3/remote_consoles.py

/usr/lib/python2.7/dist-packages/nova/compute/api.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/api.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/compute/api.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/compute/api.py

/usr/lib/python2.7/dist-packages/nova/compute/cells_api.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/cells_api.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/compute/cells_api.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/compute/cells_api.py

/usr/lib/python2.7/dist-packages/nova/compute/manager.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/manager.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/compute/manager.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/compute/manager.py

/usr/lib/python2.7/dist-packages/nova/compute/rpcapi.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/rpcapi.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/compute/rpcapi.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/compute/rpcapi.py

/usr/lib/python2.7/dist-packages/nova/console/websocketproxy.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/websocketproxy.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/console/websocketproxy.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/console/websocketproxy.py

/usr/lib/python2.7/dist-packages/nova/exception.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/exception.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/exception.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/exception.py

/usr/lib/python2.7/dist-packages/nova/network/model.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/model.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/network/model.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/network/model.py

/usr/lib/python2.7/dist-packages/nova/virt/configdrive.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/configdrive.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/configdrive.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/configdrive.py

/usr/lib/python2.7/dist-packages/nova/virt/driver.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/virt.driver.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/driver.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/driver.py

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/libvirt.driver.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py

/usr/lib/python2.7/dist-packages/nova/virt/hardware.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/hardware.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/hardware.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/hardware.py

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/config.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/config.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/libvirt/config.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/config.py

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/vif.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/vif.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/libvirt/vif.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/vif.py

