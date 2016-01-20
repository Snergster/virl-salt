{% set public_ip = salt['pillar.get']('virl:static_ip', salt['grains.get']('static_ip', '127.0.0.1' )) %}
{% set serstart = salt['pillar.get']('virl:start_of_serial_port_range', salt['grains.get']('start_of_serial_port_range', '17000')) %}
{% set serend = salt['pillar.get']('virl:end_of_serial_port_range', salt['grains.get']('end_of_serial_port_range', '18000')) %}
{% set ramdisk = salt['pillar.get']('virl:ramdisk', salt['grains.get']('ramdisk', False)) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set rabbitpassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set neutronpassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set novapassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set iscontroller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True)) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set controllerhostname = salt['pillar.get']('virl:internalnet_controller_hostname',salt['grains.get']('internalnet_controller_hostname', 'controller')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}
{% set cluster = salt['pillar.get']('virl:virl_cluster', salt['grains.get']('virl_cluster', False )) %}

include:
  - virl.ramdisk
  - common.kvm

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

{% if not kilo %}
oslo messaging 11 prevent:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - require:
      - pkg: nova-pkgs
    - names:
      - oslo.messaging == 1.6.0
      - oslo.config == 1.6.0
      - pbr == 0.10.8
{% endif %}

/etc/nova:
  file.directory:
    - dir_mode: 755

/etc/nova/nova.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://openstack/nova/files/kilo.nova.conf"
    - require:
      - pkg: nova-pkgs

{% if cluster %}
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
    - source: "salt://openstack/nova/files/kilo.serial.html"
    - makedirs: True
    - user: nova
    - group: nova
    - mode: 0644
    - require:
      - pkg: nova-pkgs

/usr/lib/python2.7/dist-packages/nova/console/serial.html:
  file.managed:
    - source: "salt://openstack/nova/files/kilo.serial.html"
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
    - value: '{{ serstart }}:{{ serend }}'
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
        'dpkg-statoverride  --update --add root root 0644 /boot/vmlinuz-$(uname -r)'
        service nova-cert restart
        service nova-api restart
        service nova-consoleauth restart
        service nova-scheduler restart
        service nova-conductor restart
        service nova-compute restart
        service nova-novncproxy restart
        service nova-serialproxy restart
