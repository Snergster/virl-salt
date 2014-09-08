{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set mypassword = salt['grains.get']('mysql_password', 'password') %}
{% set metapassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set neutid = salt['grains.get']('neutron_guestid', ' ') %}
{% set int_ip = salt['grains.get']('internalnet_ip', '172.16.10.250' ) %}
{% set l2_port = salt['grains.get']('l2_port', 'eth1' ) %}
{% set l2_address = salt['grains.get']('l2_address', '172.16.1.254' ) %}
{% set l2_address2 = salt['grains.get']('l2_address2', '172.16.2.254' ) %}
{% set l3_address = salt['grains.get']('l3_address', '172.16.3.254' ) %}
{% set l2_port2 = salt['grains.get']('l2_port2', 'eth2' ) %}
{% set l2_port2_enabled = salt['grains.get']('l2_port2_enabled', 'True' ) %}
{% set l3_port = salt['grains.get']('l3_port', 'eth3' ) %}

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

linuxbridge_apt_add:
  file.append:
    - order: 3
    - name: /etc/apt/preferences.d/cisco-openstack
    - text: |
        Package: neutron-plugin-linuxbridge-agent
        Pin: release *
        Pin-Priority: -1

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
    - value: 'mysql://neutron:{{ mypassword }}@127.0.0.1/neutron'

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
    - value: 'mysql://neutron:{{ mypassword }}@127.0.0.1/neutron'


neutron-plugin-localip:
  openstack_config.present:
    - filename: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
    - section: 'vxlan'
    - parameter: 'local_ip'
    - value: ' {{ int_ip}}'

neutron-provider-networks:
  openstack_config.present:
    - filename: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
    - section: 'linux_bridge'
    - parameter: 'network_vlan_ranges'
    {% if l2_port2 == True %}
    - value: 'flat:{{ l2_port }},flat2:{{ l2_port2 }},ext-net:{{ l3_port }}'
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

## {% for each in ["dhcp-agent","l3-agent","metadata-agent","plugin-linuxbridge-agent","server"] %}
## /etc/init/neutron-{{ each }}.conf:
##   file.replace:
##     - pattern: ^start on runlevel \[2345\]$
##     - repl: 'start on runlevel [2345] and stopped rc'
##     - backup: ''
##     - require:
##       - pkg: neutron-pkgs
## {% endfor %}

neutron db-sync:
  cmd.run:
    - name: |
        service neutron-server restart
        sysctl -p
