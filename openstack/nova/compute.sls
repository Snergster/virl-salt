
{% from "virl.jinja" import virl with context %}

compute-pkgs:
  pkg.installed:
    - refresh: True
    - names:
      - nova-compute
      - python-novaclient
      - nova-serialproxy

/etc/nova permissions check:
  file.directory:
    - name: /etc/nova
    - dir_mode: 0755

/etc/nova/nova.conf:
  file.managed:
    - mode: 755
    - template: jinja
{% if virl.mitaka %}
    - source: "salt://openstack/nova/files/compute.nova.conf"
{% else %}
    - source: "salt://openstack/nova/files/compute.nova.conf"
{% endif %}
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
    - value: {{ virl.int_ip }}
    - require:
      - file: /etc/nova/nova.conf

serial_console tune2:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'serial_console'
    - parameter: 'serial_port_proxyclient_address'
    - value: {{ virl.int_ip }}
    - require:
      - file: /etc/nova/nova.conf

glance tune:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'glance'
    - parameter: 'host'
    - value: {{ virl.controller_ip }}
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
    - value: {{ virl.int_ip }}
    - require:
      - file: /etc/nova/nova.conf

compute filter for compute paranoia:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'scheduler_default_filters'
    - value: 'AllHostsFilter,ComputeFilter'
    - require:
      - file: /etc/nova/nova.conf

my_ip compute paranoia:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'my_ip'
    - value: '{{  salt['pillar.get']('virl:internalnet_ip', '172.16.10.250' ) }}'
    - require:
      - file: /etc/nova/nova.conf


{% if virl.mitaka %}

{% for basepath in [
    'nova+api+openstack+compute+legacy_v2+contrib+consoles.py',
    'nova+api+openstack+compute+remote_consoles.py',
    'nova+api+openstack+compute+schemas+remote_consoles.py',
    'nova+cmd+baseproxy.py',
    'nova+cmd+serialproxy.py',
    'nova+compute+api.py',
    'nova+compute+cells_api.py',
    'nova+compute+manager.py',
    'nova+compute+rpcapi.py',
    'nova+console+websocketproxy.py',
    'nova+exception.py',
    'nova+network+neutronv2+api.py',
    'nova+virt+configdrive.py',
    'nova+virt+driver.py',
    'nova+virt+hardware.py',
    'nova+virt+libvirt+blockinfo.py',
    'nova+virt+libvirt+config.py',
    'nova+virt+libvirt+driver.py',
    'nova+virt+libvirt+vif.py',
    'nova+network+model.py',
    'nova+objects+fields.py',
    'nova+objects+image_meta.py',
] %}

{% set realpath = '/usr/lib/python2.7/dist-packages/' + basepath.replace('+', '/') %}
{{ realpath }}:
  file.managed:
    - source: salt://openstack/nova/files/mitaka/{{ basepath }}
  cmd.wait:
    - names:
      - python -m compileall {{ realpath }}
    - watch:
      - file: {{ realpath }}
    - require:
      - pkg: compute-pkgs

{% endfor %}

{% else %}

/usr/lib/python2.7/dist-packages/nova/cmd/serialproxy.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/serialproxy.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/cmd/serialproxy.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/cmd/serialproxy.py

/usr/lib/python2.7/dist-packages/nova/cmd/baseproxy.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/baseproxy.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/cmd/baseproxy.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/cmd/baseproxy.py


/usr/lib/python2.7/dist-packages/nova/api/openstack/compute/contrib/consoles.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/consoles.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/contrib/consoles.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/contrib/consoles.py

/usr/lib/python2.7/dist-packages/nova/api/openstack/compute/plugins/v3/remote_consoles.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/plugin.remote_consoles.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/plugins/v3/remote_consoles.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/plugins/v3/remote_consoles.py

/usr/lib/python2.7/dist-packages/nova/api/openstack/compute/schemas/v3/remote_consoles.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/schemas.remote_consoles.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/schemas/v3/remote_consoles.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/api/openstack/compute/schemas/v3/remote_consoles.py

/usr/lib/python2.7/dist-packages/nova/compute/api.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/api.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/compute/api.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/compute/api.py

/usr/lib/python2.7/dist-packages/nova/compute/cells_api.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/cells_api.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/compute/cells_api.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/compute/cells_api.py

/usr/lib/python2.7/dist-packages/nova/compute/manager.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/manager.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/compute/manager.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/compute/manager.py

/usr/lib/python2.7/dist-packages/nova/compute/rpcapi.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/rpcapi.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/compute/rpcapi.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/compute/rpcapi.py

/usr/lib/python2.7/dist-packages/nova/console/websocketproxy.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/websocketproxy.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/console/websocketproxy.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/console/websocketproxy.py

/usr/lib/python2.7/dist-packages/nova/exception.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/exception.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/exception.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/exception.py

/usr/lib/python2.7/dist-packages/nova/network/model.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/model.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/network/model.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/network/model.py

/usr/lib/python2.7/dist-packages/nova/virt/configdrive.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/configdrive.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/configdrive.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/configdrive.py

/usr/lib/python2.7/dist-packages/nova/virt/driver.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/virt.driver.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/driver.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/driver.py

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/blockinfo.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/blockinfo.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/libvirt/blockinfo.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/blockinfo.py

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/libvirt.driver.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py

/usr/lib/python2.7/dist-packages/nova/virt/hardware.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/hardware.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/hardware.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/hardware.py

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/config.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/config.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/libvirt/config.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/config.py

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/vif.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/vif.py
    - require:
      - pkg: compute-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/libvirt/vif.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/vif.py

{% endif %}

nova-compute restart:
  cmd.run:
    - order: last
    - require:
      - pkg: nova-compute
      - file: /etc/nova/nova.conf
    - name: service nova-compute restart
