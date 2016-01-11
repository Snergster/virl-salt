{% set ospassword = salt['grains.get']('password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set metapassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set neutid = salt['grains.get']('neutron_guestid', ' ') %}
{% set int_ip = salt['grains.get']('internalnet_ip', '172.16.10.250' ) %}
{% set controllerhname = salt['grains.get']('internalnet_controller_hostname', 'controller') %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set neutronpassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}

neutron-pkgs:
  pkg.installed:
    - order: 1
    - refresh: False
    - names:
      - neutron-common
      - neutron-plugin-ml2
      - neutron-plugin-linuxbridge-agent

/etc/neutron/neutron.conf:
  file.managed:
    - order: 2
    - makedirs: True
    - mode: 755
    - source: "salt://files/neutron.conf"

linuxbridge_neutron_agent.py:
  file.managed:
    - order: 3
    - name: /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py
    - mode: 755
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
    - mode: 755
    - makedirs: True
    - source: "salt://files/linuxbridge_conf.ini"

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
    - order: 4
    - mode: 755
    - makedirs: True
    - source: "salt://files/ml2_conf.ini"

neutron-conn:
  openstack_config.present:
    - section: 'database'
    - parameter: 'sql_connection'
    - name: /etc/neutron/neutron.conf
    - value: 'mysql://neutron:{{ neutronpassword }}@{{ controllerip }}/neutron'


neutron-brex:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: '# external_network_bridge = br-ex'
    - repl: 'external_network_bridge = '

neutron-plugin-conn:
  openstack_config.present:
    - section: 'database'
    - parameter: 'sql_connection'
    - name: /etc/neutron/plugins/ml2/ml2_conf.ini
    - value: 'mysql://neutron:{{ neutronpassword }}@{{ controllerip }}/neutron'


neutron-plugin-localip:
  openstack_config.present:
    - filename: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
    - section: 'vxlan'
    - parameter: 'local_ip'
    - value: ' {{ int_ip }}'


neutron-hostname:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: 'controller'
    - repl: '{{ controllerhname }}'

neutron-verbose:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: 'verbose=True'
    - repl: 'verbose=False'

neutron-password:
  file.replace:
    - name: /etc/neutron/neutron.conf
    - pattern: 'NEUTRON_PASS'
    - repl: '{{ neutronpassword }}'

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
