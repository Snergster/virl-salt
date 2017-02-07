
{% from "virl.jinja" import virl with context %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}

neutron-pkgs:
  pkg.installed:
    - force_yes: True
    - refresh: False
    - pkgs:
        - neutron-plugin-linuxbridge-agent
{% if not virl.mitaka %}
    - hold: True
    - fromrepo: trusty-updates/kilo
{% endif %}

{% if virl.mitaka %}
/etc/neutron/neutron.conf:
  file.managed:
    - template: jinja
    - makedirs: True
    - mode: 755
    - source: "salt://openstack/neutron/files/mitaka.neutron.conf"
    - require:
      - pkg: neutron-pkgs

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
    - mode: 755
    - template: jinja
    - makedirs: True
    - source: "salt://openstack/neutron/files/plugins/ml2/mitaka.ml2_conf.ini"
    - require:
      - pkg: neutron-pkgs

/etc/neutron/plugins/ml2/linuxbridge_agent.ini:
  file.managed:
    - mode: 755
    - template: jinja
    - makedirs: True
    - source: "salt://openstack/neutron/files/plugins/linuxbridge/mitaka.linuxbridge_agent.ini"
    - require:
      - pkg: neutron-pkgs

neutron rabbit host:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'oslo_messaging_rabbit'
    - parameter: 'rabbit_host'
    - value: '{{ virl.controller_ip }}'
    - require:
      - file: /etc/neutron/neutron.conf

{% else %}
/etc/neutron/neutron.conf:
  file.managed:
    - template: jinja
    - makedirs: True
    - mode: 755
    - source: "salt://openstack/neutron/files/kilo.neutron.conf"
    - require:
      - pkg: neutron-pkgs

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
    - mode: 755
    - template: jinja
    - makedirs: True
    - source: "salt://openstack/neutron/files/plugins/ml2/kilo.ml2_conf.ini"
    - require:
      - pkg: neutron-pkgs

neutron rabbit host:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_host'
    - value: '{{ virl.controller_ip }}'
    - require:
      - file: /etc/neutron/neutron.conf

{% endif %}

/etc/init/neutron-server.conf:
  file.managed:
    - mode: 644
    - makedirs: True
    - source: "salt://openstack/neutron/files/kilo.neutron-server.conf"
    - require:
      - pkg: neutron-pkgs

{% if 'xenial' in salt['grains.get']('oscodename') %}
neutron-sysctl:
  file.replace:
    - name: /etc/sysctl.d/10-network-security.conf
    - pattern: '#net.ipv4.conf.default.rp_filter=1'
    - repl: 'net.ipv4.conf.default.rp_filter=0'

neutron-sysctl all:
  file.replace:
    - name: /etc/sysctl.d/10-network-security.conf
    - pattern: 'net.ipv4.conf.all.rp_filter=1'
    - repl: 'net.ipv4.conf.all.rp_filter=0'

{% else %}

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

{% endif %}

neutron-sysctlforward:
  file.replace:
    - name: /etc/sysctl.conf
    - pattern: '#net.ipv4.ip_forward=1'
    - repl: 'net.ipv4.ip_forward=1'



{% if virl.controller %}
neutron-dhcp-nameserver:
  openstack_config.present:
    - filename: /etc/neutron/dhcp_agent.ini
    - section: 'DEFAULT'
    - parameter: 'dnsmasq_dns_servers'
    - value: '{{ virl.snat_dns }},{{ virl.snat_dns2 }}'
    - require:
      - file: /etc/neutron/neutron.conf

meta-tenname:
  openstack_config.present:
    - filename: /etc/neutron/metadata_agent.ini
    - section: 'DEFAULT'
    - parameter: 'admin_tenant_name'
    - value: 'service'
    - require:
      - pkg: neutron-pkgs

meta-user:
  openstack_config.present:
    - filename: /etc/neutron/metadata_agent.ini
    - section: 'DEFAULT'
    - parameter: 'admin_user'
    - value: 'neutron'
    - require:
      - pkg: neutron-pkgs

meta-pass:
  openstack_config.present:
    - filename: /etc/neutron/metadata_agent.ini
    - section: 'DEFAULT'
    - parameter: 'admin_password'
    - value: '{{ virl.ospassword }}'
    - require:
      - pkg: neutron-pkgs

meta-meta:
  openstack_config.present:
    - filename: /etc/neutron/metadata_agent.ini
    - section: 'DEFAULT'
    - parameter: 'nova_metadata_ip'
    - value: ' {{ virl.public_ip }}'
    - require:
      - pkg: neutron-pkgs

l3-interface:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'interface_driver'
    - value: ' neutron.agent.linux.interface.BridgeInterfaceDriver'
    - require:
      - pkg: neutron-pkgs

l3-agent:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'l3_agent_manager'
    - value: ' neutron.agent.l3_agent.L3NATAgentWithStateReport'
    - require:
      - pkg: neutron-pkgs

l3-mtu:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'network_device_mtu'
    - value: '1500'
    - require:
      - pkg: neutron-pkgs


dhcp-interface:
  openstack_config.present:
    - filename: /etc/neutron/dhcp_agent.ini
    - section: DEFAULT
    - parameter: 'interface_driver'
    - value: ' neutron.agent.linux.interface.BridgeInterfaceDriver'
    - require:
      - pkg: neutron-pkgs

dhcp-namespace:
  openstack_config.present:
    - filename: /etc/neutron/dhcp_agent.ini
    - section: DEFAULT
    - parameter: 'use_namespaces'
    - value: ' True'
    - require:
      - pkg: neutron-pkgs

dhcp-driver:
  openstack_config.present:
    - filename: /etc/neutron/dhcp_agent.ini
    - section: DEFAULT
    - parameter: 'dhcp_driver'
    - value: ' neutron.agent.linux.dhcp.Dnsmasq'
    - require:
      - pkg: neutron-pkgs

l3-namespace:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'use_namespaces'
    - value: ' True'
    - require:
      - pkg: neutron-pkgs

l3-dhcp:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'dhcp_driver'
    - value: ' neutron.agent.linux.dhcp.Dnsmasq'
    - require:
      - pkg: neutron-pkgs

l3-netbridge:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'external_network_bridge'
    - value: ' '
    - require:
      - pkg: neutron-pkgs

l3-gateway:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'gateway_external_network_id'
    - value: ' '
    - require:
      - pkg: neutron-pkgs

{% endif %}

{% if virl.mitaka %}

/etc/neutron/rootwrap.d/linuxbridge-plugin.filters:
  file.managed:
    - source: "salt://openstack/neutron/files/mitaka/linuxbridge-plugin.filters"
    - require:
      - pkg: neutron-pkgs

{% for basepath in [
    'neutron+agent+linux+bridge_lib.py',
    'neutron+agent+linux+ip_lib.py',
    'neutron+plugins+ml2+drivers+agent+_common_agent.py',
    'neutron+plugins+ml2+drivers+linuxbridge+agent+common+config.py',
    'neutron+plugins+ml2+drivers+linuxbridge+agent+linuxbridge_neutron_agent.py',
    'neutron+plugins+ml2+plugin.py',
    'neutron+plugins+ml2+rpc.py',
    'neutron+common+utils.py',
] %}

{% set realpath = '/usr/lib/python2.7/dist-packages/' + basepath.replace('+', '/') %}
{{ realpath }}:
  file.managed:
    - makedirs: True
    - source: salt://openstack/neutron/files/mitaka/{{ basepath }}
  cmd.wait:
    - names:
      - python -m compileall {{ realpath }}
    - watch:
      - file: {{ realpath }}
    - require:
      - pkg: neutron-pkgs

{% endfor %}

{% else %}

/etc/neutron/rootwrap.d/linuxbridge-plugin.filters:
  file.managed:
    - source: "salt://openstack/neutron/files/kilo.linuxbridge-plugin.filters"
    - require:
      - pkg: neutron-pkgs

/usr/lib/python2.7/dist-packages/neutron/agent/linux/ip_lib.py:
  file.managed:
    - source: salt://openstack/neutron/files/kilo/ip_lib.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/agent/linux/ip_lib.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/agent/linux/ip_lib.py
    - require:
      - pkg: neutron-pkgs

/usr/lib/python2.7/dist-packages/neutron/agent/linux/bridge_lib.py:
  file.managed:
    - source: salt://openstack/neutron/files/kilo/bridge_lib.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/agent/linux/bridge_lib.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/agent/linux/bridge_lib.py
    - require:
      - pkg: neutron-pkgs

/usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py:
  file.managed:
    - source: salt://openstack/neutron/files/kilo/linuxbridge_neutron_agent.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py
    - require:
      - pkg: neutron-pkgs

/usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/common/config.py:
  file.managed:
    - source: salt://openstack/neutron/files/kilo/config.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/common/config.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/common/config.py
    - require:
      - pkg: neutron-pkgs

/usr/lib/python2.7/dist-packages/neutron/plugins/ml2/plugin.py:
  file.managed:
    - source: salt://openstack/neutron/files/kilo/plugin.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/plugins/ml2/plugin.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/plugins/ml2/plugin.py
    - require:
      - pkg: neutron-pkgs

/usr/lib/python2.7/dist-packages/neutron/plugins/ml2/rpc.py:
  file.managed:
    - source: salt://openstack/neutron/files/kilo/rpc.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/plugins/ml2/rpc.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/plugins/ml2/rpc.py
    - require:
      - pkg: neutron-pkgs
{% endif %}
