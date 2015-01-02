{% set rabbitpassword = salt['pillar.get']('virl:rabbitpassword', salt['grains.get']('password', 'password')) %}
{% set metapassword = salt['pillar.get']('virl:metapassword', salt['grains.get']('password', 'password')) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set neutronpassword = salt['pillar.get']('virl:neutronpassword', salt['grains.get']('password', 'password')) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set public_ip = salt['pillar.get']('virl:static_ip', salt['grains.get']('static_ip', '127.0.0.1' )) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP', salt['grains.get']('internalnet_controller_IP', '172.16.10.250')) %}
{% set l2_port2_enabled = salt['pillar.get']('virl:l2_port2_enabled', salt['grains.get']('l2_port2_enabled', 'True' )) %}
{% set l2_port = salt['pillar.get']('virl:l2_port', salt['grains.get']('l2_port', 'eth1' )) %}
{% set l2_network = salt['pillar.get']('virl:l2_network', salt['grains.get']('l2_network', '172.16.1.0/24' )) %}
{% set l2_gateway = salt['pillar.get']('virl:l2_network_gateway', salt['grains.get']('l2_network_gateway', '172.16.1.1' )) %}
{% set l2_start_address = salt['pillar.get']('virl:l2_start_address', salt['grains.get']('l2_start_address', '172.16.1.50' )) %}
{% set l2_end_address = salt['pillar.get']('virl:l2_end_address', salt['grains.get']('l2_end_address', '172.16.1.253' )) %}
{% set l2_address = salt['pillar.get']('virl:l2_address', salt['grains.get']('l2_address', '172.16.1.254' )) %}
{% set l2_address2 = salt['pillar.get']('virl:l2_address2', salt['grains.get']('l2_address2', '172.16.2.254' )) %}
{% set l3_port = salt['pillar.get']('virl:l3_port', salt['grains.get']('l3_port', 'eth3' )) %}
{% set l3_network = salt['pillar.get']('virl:l3_mask', salt['grains.get']('l3_mask', '172.16.3.0/24' )) %}
{% set l3_mask = salt['pillar.get']('virl:l3_mask', salt['grains.get']('l3_mask', '255.255.255.0' )) %}
{% set l3_network_gateway = salt['pillar.get']('virl:l3_network_gateway', salt['grains.get']('l3_network_gateway', '172.16.3.1' )) %}
{% set l3_floating_start_address = salt['pillar.get']('virl:l3_floating_start_address', salt['grains.get']('l3_floating_start_address', '172.16.3.50' )) %}
{% set l3_floating_end_address = salt['pillar.get']('virl:l3_floating_end_address', salt['grains.get']('l3_floating_end_address', '172.16.3.253' )) %}
{% set l3_address = salt['pillar.get']('virl:l3_address', salt['grains.get']('l3_address', '172.16.3.254/24' )) %}
{% set l2_port2 = salt['pillar.get']('virl:l2_port2', salt['grains.get']('l2_port2', 'eth2' )) %}
{% set jumbo_frames = salt['pillar.get']('virl:jumbo_frames', salt['grains.get']('jumbo_frames', False )) %}
{% set service_tenid = salt['grains.get']('service_id', ' ' ) %}
{% set neutid = salt['grains.get']('neutron_guestid', ' ') %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_IP', '172.16.10.250')) %}

neutron-pkgs:
  pkg.installed:
    - order: 1
    - refresh: False
    - names:
      - neutron-server
      - neutron-common
      - neutron-l3-agent
      - neutron-dhcp-agent
      - neutron-plugin-ml2
      - neutron-plugin-linuxbridge-agent

/etc/neutron/neutron.conf:
  file.managed:
    - order: 2
    - makedirs: True
    - file_mode: 755
    - source: "salt://files/neutron.conf"

neutron-mtu:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'network_device_mtu'
{% if jumbo_frames == True %}
    - value: '9100'
{% else %}
    - value: '1550'
{% endif %}
    - require:
      - file: /etc/neutron/neutron.conf

/usr/lib/python2.7/dist-packages/neutron/extensions/l3.py:
  file.patch:
    - source: salt://files/patches/l3.py.patch
    - hash: md5=3739e6a7463a3e2102b76d1cc3ebeff6
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/extensions/l3.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/extensions/l3.py
    - require:
      - pkg: neutron-pkgs

/usr/lib/python2.7/dist-packages/neutron/db/l3_db.py:
  file.patch:
    - source: salt://files/patches/l3_db.patch
    - hash: md5=c99c80ba6aa209fcd046a972af51a914
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/db/l3_db.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/db/l3_db.py
    - require:
      - pkg: neutron-pkgs

/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini:
  file.managed:
    - order: 4
    - file_mode: 755
    - makedirs: True
    - source: "salt://files/linuxbridge_conf.ini"

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
    - order: 4
    - file_mode: 755
    - makedirs: True
    - source: "salt://files/ml2_conf.ini"

neutron-conn:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://neutron:{{ mypassword }}@{{ controllerip }}/neutron'

neutron-brex:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: '# external_network_bridge = br-ex'
    - repl: 'external_network_bridge = '

neutron-plugin-conn:
  openstack_config.present:
    - filename: /etc/neutron/plugins/ml2/ml2_conf.ini
    - section: 'database'
    - parameter: 'sql_connection'
    - value: 'mysql://neutron:{{ mypassword }}@{{ controllerip }}/neutron'


neutron-plugin-localip:
  openstack_config.present:
    - filename: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
    - section: 'vxlan'
    - parameter: 'local_ip'
    - value: ' {{ controllerip }}'

neutron-provider-networks:
  openstack_config.present:
    - filename: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
    - section: 'vlans'
    - parameter: 'network_vlan_ranges'
    {% if l2_port2_enabled == True %}
    - value: 'flat,flat1,ext-net'
    {% else %}
    - value: 'flat,ext-net'
    {% endif %}

neutron-provider-networks-phymap:
  openstack_config.present:
    - filename: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
    - section: 'linux_bridge'
    - parameter: 'physical_interface_mappings'
    {% if l2_port2_enabled == True %}
    - value: 'flat:{{ l2_port }},flat1:{{ l2_port2 }},ext-net:{{ l3_port }}'
    {% else %}
    - value: 'flat:{{ l2_port }},ext-net:{{ l3_port }}'
    {% endif %}

neutron-hostname:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_url'
    - value: 'http://{{ hostname }}:8774/v2'

neutron-hostname2:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_admin_auth_url'
    - value: 'http://{{ hostname }}:35357/v2.0'

neutron-hostname3:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_uri'
    - value: 'http://{{ hostname }}:5000'

neutron-hostname4:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_host'
    - value: '{{ hostname }}'

neutron-serviceid:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_admin_tenant_id'
    - value: '{{ service_tenid }}'

neutron-verbose:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: 'verbose=True'
    - repl: 'verbose=False'

neutron-password1:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_admin_password'
    - value: '{{ neutronpassword }}'

neutron-password2:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_password'
    - value: '{{ neutronpassword }}'

neutron-tenname:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: 'admin_tenant_name = %SERVICE_TENANT_NAME%'
    - repl: 'admin_tenant_name = service'

neutron-user:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: 'admin_user = %SERVICE_USER%'
    - repl: 'admin_user = neutron'

neutron-pass:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: 'admin_password = %SERVICE_PASSWORD%'
    - repl: 'admin_password = {{ ospassword }}'


meta-tenname:
  file.replace:
    - name: /etc/neutron/metadata_agent.ini
    - pattern: 'admin_tenant_name = %SERVICE_TENANT_NAME%'
    - repl: 'admin_tenant_name = service'

meta-user:
  file.replace:
    - name: /etc/neutron/metadata_agent.ini
    - pattern: 'admin_user = %SERVICE_USER%'
    - repl: 'admin_user = neutron'

meta-pass:
  file.replace:
    - name: /etc/neutron/metadata_agent.ini
    - pattern: 'admin_password = %SERVICE_PASSWORD%'
    - repl: 'admin_password = {{ ospassword }}'

meta-meta:
  openstack_config.present:
    - filename: /etc/neutron/metadata_agent.ini
    - section: 'DEFAULT'
    - parameter: 'nova_metadata_ip'
    - value: ' {{ public_ip }}'

l3-interface:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'interface_driver'
    - value: ' neutron.agent.linux.interface.BridgeInterfaceDriver'

l3-agent:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'l3_agent_manager'
    - value: ' neutron.agent.l3_agent.L3NATAgentWithStateReport'

l3-mtu:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'network_device_mtu'
    - value: '1500'


dhcp-interface:
  openstack_config.present:
    - filename: /etc/neutron/dhcp_agent.ini
    - section: DEFAULT
    - parameter: 'interface_driver'
    - value: ' neutron.agent.linux.interface.BridgeInterfaceDriver'

dhcp-namespace:
  openstack_config.present:
    - filename: /etc/neutron/dhcp_agent.ini
    - section: DEFAULT
    - parameter: 'use_namespaces'
    - value: ' True'

dhcp-driver:
  openstack_config.present:
    - filename: /etc/neutron/dhcp_agent.ini
    - section: DEFAULT
    - parameter: 'dhcp_driver'
    - value: ' neutron.agent.linux.dhcp.Dnsmasq'

l3-namespace:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'use_namespaces'
    - value: ' True'

l3-dhcp:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'dhcp_driver'
    - value: ' neutron.agent.linux.dhcp.Dnsmasq'

l3-netbridge:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'external_network_bridge'
    - value: ' '

l3-gateway:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'gateway_external_network_id'
    - value: ' '

neutron-rabbitpass:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_password'
    - value: ' {{ rabbitpassword }}'

neutron-serviceplugin:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: '# service_plugins ='
    - repl: 'service_plugins = router'

neutron-overlap:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: '# allow_overlapping_ips = False'
    - repl: 'allow_overlapping_ips = True'

neutron-sysctl:
  file.replace:
    - name: /etc/sysctl.conf
    - pattern: '#net.ipv4.conf.default.rp_filter=1'
    - repl: 'net.ipv4.conf.default.rp_filter=0'

neutron-sysctl2:
  file.replace:
    - name: /etc/sysctl.conf
    - pattern: '#net.ipv4.conf.all.rp_filter=1'
    - repl: 'net.ipv4.conf.all.rp_filter=0'

neutron-sysctlforward:
  file.replace:
    - name: /etc/sysctl.conf
    - pattern: '#net.ipv4.ip_forward=1'
    - repl: 'net.ipv4.ip_forward=1'

linuxbridge_neutron_agent.py:
  file.managed:
    - order: 3
    - name: /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py
    - file_mode: 755
    - makedirs: True
    - source: "salt://files/linuxbridge_neutron_agent.py"
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py
    - watch:
      - file: linuxbridge_neutron_agent.py

linuxbridge hold:
  apt.held:
    - name: neutron-plugin-linuxbridge-agent
    - require:
      - file: linuxbridge_neutron_agent.py

neutron db-sync:
  cmd.run:
    - order: last
    - name: |
        service neutron-server restart
        sysctl -p
