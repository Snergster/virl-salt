{% from "virl.jinja" import virl with context %}

include:
  - virl.ramdisk
  - common.kvm

redis-py:
  pip.installed:
    - name: redis>=2.10.5
    {% if virl.proxy %}
    - proxy: {{ virl.http_proxy }}
    {% endif %}

nova-api:
  pkg.installed:
    - name: nova-api
    - refresh: true

nova-pkgs:
  pkg.installed:
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

{% if virl.mitaka %}
/lib/systemd/system/nova-serialproxy.service:
  file.absent
/etc/systemd/system/multi-user.target.wants/nova-serialproxy.service:
  file.absent
nova-serialproxy systemd reload:
  cmd.run:
    - name: systemctl daemon-reload
{% endif %}


/etc/nova:
  file.directory:
    - dir_mode: 755

{% if virl.mitaka %}
/etc/nova/nova.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://openstack/nova/files/mitaka.nova.conf"
    - require:
      - pkg: nova-pkgs
{% else %}
/etc/nova/nova.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://openstack/nova/files/kilo.nova.conf"
    - require:
      - pkg: nova-pkgs
{% endif %}

{% if virl.dhcp %}

my ip for dhcp to static:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'my_ip'
    - value: '127.0.0.1'
    - require:
      - file: /etc/nova/nova.conf

vnc_server for dhcp to static:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'vncserver_listen'
    - value: '127.0.0.1'
    - require:
      - file: /etc/nova/nova.conf

vnc_server proxy for dhcp to static:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'vncserver_proxyclient_address'
    - value: '127.0.0.1'
    - require:
      - file: /etc/nova/nova.conf

{% endif %}

{% if virl.cluster %}
compute filter for cluster:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'scheduler_default_filters'
    - value: 'AllHostsFilter,ComputeFilter'
    - require:
      - file: /etc/nova/nova.conf

{% endif %}

add libvirt-qemu to nova:
  group.present:
    - name: nova
    - delusers:
      - libvirt-qemu

{% if virl.mitaka %}

{% for basepath in [
    'nova+api+openstack+compute+legacy_v2+contrib+consoles.py',
    'nova+api+openstack+compute+remote_consoles.py',
    'nova+api+openstack+compute+schemas+remote_consoles.py',
    'nova+cmd+baseproxy.py',
    'nova+cmd+serialproxy.py',
    'nova+conf+serial_console.py',
    'nova+compute+api.py',
    'nova+compute+cells_api.py',
    'nova+compute+manager.py',
    'nova+compute+rpcapi.py',
    'nova+console+websocketproxy.py',
    'nova+exception.py',
    'nova+image+glance.py',
    'nova+network+neutronv2+api.py',
    'nova+utils.py',
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
      - pkg: nova-pkgs

{% endfor %}

{% else %}

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

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/blockinfo.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/blockinfo.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virt/libvirt/blockinfo.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/blockinfo.py

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

/usr/lib/python2.7/dist-packages/nova/network/neutronv2/api.py:
  file.managed:
    - source: salt://openstack/nova/files/kilo/network.neutronv2.api.py
    - require:
      - pkg: nova-pkgs
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/network/neutronv2/api.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/network/neutronv2/api.py

{% endif %}

{% for each in ['cert','api','serialproxy','conductor','compute','scheduler','novncproxy','consoleauth'] %}
nova-{{each}} conf:
  file.replace:
    - name: /etc/init/nova-{{each}}.conf
    - pattern: '^start on runlevel \[2345\]'
    - repl: 'start on (rabbitmq-server-running or started rabbitmq-server)'
{% endfor %}



/etc/nova/policy.json:
  file.managed:
    - source: "salt://openstack/nova/files/kilo.policy.json"
    - user: nova
    - group: nova
    - mode: 0640
    - require:
      - pkg: nova-pkgs

/usr/share/nova-serial/serial.html:
  file.managed:
    - source: "salt://openstack/nova/files/serial.html"
    - makedirs: True
    - user: nova
    - group: nova
    - mode: 0644
    - require:
      - pkg: nova-pkgs

/usr/lib/python2.7/dist-packages/nova/console/serial.html:
  file.managed:
    - source: "salt://openstack/nova/files/serial.html"
    - user: nova
    - group: nova
    - mode: 0644
    - require:
      - pkg: nova-pkgs

/usr/share/nova-serial/term.js:
  file.managed:
    - source: "salt://openstack/nova/files/term.js"
    - makedirs: True
    - user: nova
    - group: nova
    - mode: 0644
    - require:
      - pkg: nova-pkgs

/usr/lib/python2.7/dist-packages/nova/console/term.js:
  file.managed:
    - source: "salt://openstack/nova/files/term.js"
    - user: nova
    - group: nova
    - mode: 0644
    - require:
      - pkg: nova-pkgs

/etc/init.d/nova-serialproxy:
  file.managed:
    - source: "salt://openstack/nova/files/nova-serialproxy"
    - force: True
    - mode: 0755
    - require:
      - pkg: nova-pkgs

nova-compute serial:
  openstack_config.present:
    - filename: /etc/nova/nova-compute.conf
    - section: 'libvirt'
    - parameter: 'serial_port_range'
    - value: '{{ virl.serstart }}:{{ virl.serend }}'
    - require:
      - file: /etc/nova/nova.conf

/etc/rc2.d/S98nova-serialproxy:
  file.absent

/usr/share/novnc/vnc_auto.html:
  file.managed:
    - source: "salt://openstack/nova/files/vnc_auto.html"
    - user: nova
    - group: nova
    - mode: 0644
    - require:
      - pkg: nova-pkgs

/home/virl/.novaclient:
  file.directory:
    - user: virl
    - group: virl
    - recurse:
      - user
      - group

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
{% if virl.mitaka %}
        su -s /bin/sh -c "nova-manage api_db sync" nova
{% endif %}
        'dpkg-statoverride  --update --add root root 0644 /boot/vmlinuz-$(uname -r)'
        service nova-cert restart
        service nova-api restart
        service nova-consoleauth restart
        service nova-scheduler restart
        service nova-conductor restart
        service nova-compute restart
        service nova-novncproxy restart
        service nova-serialproxy restart
