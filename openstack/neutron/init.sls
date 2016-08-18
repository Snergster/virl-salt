{% from "virl.jinja" import virl with context %}

include:
  - openstack.keystone.setup

neutron linuxbridge unhold:
  module.run:
    - name: pkg.unhold
    - m_name: neutron-plugin-linuxbridge-agent

neutron-pkgs:
  pkg.installed:
    - force_yes: True
    - pkgs:
      - neutron-common
      - neutron-dhcp-agent
      - neutron-l3-agent
      - neutron-metadata-agent
      - neutron-plugin-linuxbridge-agent
      - neutron-plugin-ml2
      - neutron-server
      - python-neutron
{% if not virl.mitaka %}
      - neutron-plugin-linuxbridge
    - refresh: True
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
{% endif %}

/etc/init/neutron-server.conf:
  file.managed:
    - mode: 644
    - makedirs: True
    - source: "salt://openstack/neutron/files/kilo.neutron-server.conf"
    - require:
      - pkg: neutron-pkgs

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



{% if not virl.l2_port2_enabled %}
neutron-provider-networks:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'vlans'
    - parameter: 'network_vlan_ranges'
    - value: 'flat,ext-net'
    - require:
      - file: /etc/neutron/neutron.conf

neutron-provider-networks-phymap:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'linux_bridge'
    - parameter: 'physical_interface_mappings'
    - value: 'flat:{{ virl.l2_port }},ext-net:{{ virl.l3_port }}'
{% endif %}

## if needs to go here for non controller
{% if not virl.controller %}

neutron-hostname:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_url'
    - value: 'http://{{ virl.controllerhostname }}:8774/v2'
    - require:
      - file: /etc/neutron/neutron.conf

neutron-hostname2:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_admin_auth_url'
    - value: 'http://{{ virl.controllerhostname }}:35357/v2.0'
    - require:
      - file: /etc/neutron/neutron.conf

neutron-hostname3:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_uri'
    - value: 'http://{{ virl.controllerhostname }}:35357/v2.0/'
    - require:
      - file: /etc/neutron/neutron.conf


neutron-hostname-indentity:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'keystone_authtoken'
    - parameter: 'identity_uri'
    - value: 'http://{{ virl.controllerhostname }}:5000'
    - require:
      - file: /etc/neutron/neutron.conf


neutron-hostname4:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_host'
    - value: '{{ virl.controllerhostname }}'
    - require:
      - file: /etc/neutron/neutron.conf


{% endif %}

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


{% if virl.mitaka %}
{% for each in ['server','dhcp-agent','l3-agent','metadata-agent'] %}
neutron-{{each}} conf:
  file.replace:
    - name: /etc/init/neutron-{{each}}.conf
    - pattern: '^start on runlevel \[2345\]'
    - repl: 'start on (rabbitmq-server-running or started rabbitmq-server)'
{% endfor %}
{% else %}
{% for each in ['server','dhcp-agent','l3-agent','metadata-agent','plugin-linuxbridge-agent'] %}
neutron-{{each}} conf:
  file.replace:
    - name: /etc/init/neutron-{{each}}.conf
    - pattern: '^start on runlevel \[2345\]'
    - repl: 'start on (rabbitmq-server-running or started rabbitmq-server)'
{% endfor %}

{% endif%}

linuxbridge hold:
  apt.held:
    - name: neutron-plugin-linuxbridge-agent
    - require:
      - pkg: neutron-pkgs

neutron lxc bridge off in init:
  file.replace:
    - name: /etc/init/lxc-net.conf
    - pattern: '^USE_LXC_BRIDGE="true"'
    - repl: 'USE_LXC_BRIDGE="false"'

neutron lxc bridge off in default:
  file.replace:
    - name: /etc/default/lxc-net
    - pattern: '^USE_LXC_BRIDGE="true"'
    - repl: 'USE_LXC_BRIDGE="false"'


fixed ips allowed for all:
  file.replace:
    - name: /etc/neutron/policy.json
    - pattern: '^    "create_port:fixed_ips": "rule:admin_or_network_owner or rule:context_is_advsvc",' 
    - repl: '    "create_port:fixed_ips": "rule:admin_or_network_owner or rule:context_is_advsvc or rule:shared or rule:external",'
    - require:
      - pkg: neutron-pkgs

fixed macs allowed for all:
  file.replace:
    - name: /etc/neutron/policy.json
    - pattern: '^    "create_port:mac_address": "rule:admin_or_network_owner or rule:context_is_advsvc",'
    - repl: '    "create_port:mac_address": "rule:admin_or_network_owner or rule:context_is_advsvc or rule:shared or rule:external",'
    - require:
      - pkg: neutron-pkgs

port binding fix:
  file.replace:
    - name: /etc/neutron/policy.json
    - pattern: '^    "update_port:binding:host_id": "rule:admin_only",'
    - repl: '    "update_port:binding:host_id": "rule:admin_or_owner",'
    - require:
      - pkg: neutron-pkgs

neutron restart:
  cmd.run:
    - order: last
    - name: |
{% if virl.mitaka %}
        su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade mitaka" neutron
{% else %}
        su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade kilo" neutron
{% endif %}
        service neutron-server restart | at now + 1 min
        service neutron-dhcp-agent restart | at now + 1 min
        service neutron-l3-agent restart | at now + 1 min
        service neutron-metadata-agent restart | at now + 1 min
        service neutron-plugin-linuxbridge-agent restart | at now + 1 min
        sleep 65

neutron sysctl:
  cmd.run:
    - name: 'sysctl -p'
    - onchanges:
      - file: /etc/sysctl.conf
