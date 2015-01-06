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
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set controllerhostname = salt['pillar.get']('virl:internalnet_controller_hostname',salt['grains.get']('internalnet_controller_hostname', 'controller')) %}
{% set iscontroller = salt['pillar.get']('virl:iscontroller', salt['grains.get']('iscontroller', True)) %}

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
    - template: jinja
    - makedirs: True
    - file_mode: 755
    - source: "file:///srv/salt/openstack/neutron/files/neutron.conf"
    - require:
      - pkg: neutron-pkgs

/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini:
  file.managed:
    - order: 4
    - template: jinja
    - file_mode: 755
    - makedirs: True
    - source: "file:///srv/salt/openstack/neutron/files/plugins/linuxbridge/linuxbridge_conf.ini"
    - require:
      - pkg: neutron-pkgs

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
    - order: 4
    - file_mode: 755
    - template: jinja
    - makedirs: True
    - source: "file:///srv/salt/openstack/neutron/files/plugins/ml2/ml2_conf.ini"
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


{% if jumbo_frames == True %}
neutron-mtu:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'network_device_mtu'
    - value: '9100'
    - require:
      - file: /etc/neutron/neutron.conf
{% endif %}


{% if l2_port2_enabled == false %}
neutron-provider-networks:
  openstack_config.present:
    - filename: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
    - section: 'vlans'
    - parameter: 'network_vlan_ranges'
    - value: 'flat,ext-net'
    - require:
      - file: /etc/neutron/neutron.conf

neutron-provider-networks-phymap:
  openstack_config.present:
    - filename: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
    - section: 'linux_bridge'
    - parameter: 'physical_interface_mappings'
    - value: 'flat:{{ l2_port }},ext-net:{{ l3_port }}'
{% endif %}

## if needs to go here for non controller
{% if iscontroller == False %}

neutron-hostname:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_url'
    - value: 'http://{{ controllerhostname }}:8774/v2'

neutron-hostname2:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_admin_auth_url'
    - value: 'http://{{ controllerhostname }}:35357/v2.0'

neutron-hostname3:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_uri'
    - value: 'http://{{ controllerhostname }}:5000'

neutron-hostname4:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_host'
    - value: '{{ controllerhostname }}'

{% endif %}

meta-tenname:
  openstack_config.present:
    - filename: /etc/neutron/metadata_agent.ini
    - section: 'DEFAULT'
    - parameter: 'admin_tenant_name'
    - value: 'service'

meta-user:
  openstack_config.present:
    - filename: /etc/neutron/metadata_agent.ini
    - section: 'DEFAULT'
    - parameter: 'admin_user'
    - value: 'neutron'

meta-pass:
  openstack_config.present:
    - filename: /etc/neutron/metadata_agent.ini
    - section: 'DEFAULT'
    - parameter: 'admin_password'
    - value: '{{ ospassword }}'

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



/srv/salt/openstack/neutron/files/lb_neutron_plugin.py.diff:
  file.managed:
    - makedirs: True
    - file_mode: 755
    - contents: |
        102a103,105
        >                      'device_id': port['device_id'],
        >                      'device_owner': port['device_owner'],
        >                      'mac_address': port['mac_address'],
        112a116
        >         LOG.info('RPC returning %s', entry)


/srv/salt/openstack/neutron/files/l3.py.diff:
  file.managed:
    - makedirs: True
    - file_mode: 755
    - contents: |
        --- a/extensions/l3.py  2014-07-10 12:28:49.715740324 +0200
        +++ b/extensions/l3.py  2014-07-03 15:15:51.414240207 +0200
        @@ -107,7 +107,8 @@
                        'validate': {'type:uuid': None},
                        'is_visible': True,
                        'primary_key': True},
        -        'floating_ip_address': {'allow_post': False, 'allow_put': False,
        +        'floating_ip_address': {'allow_post': True, 'allow_put': False,
        +                                'default': attr.ATTR_NOT_SPECIFIED,
                                         'validate': {'type:ip_address_or_none': None},
                                         'is_visible': True},
                 'floating_network_id': {'allow_post': True, 'allow_put': False,


/srv/salt/openstack/neutron/files/l3_db.diff:
  file.managed:
    - makedirs: True
    - file_mode: 755
    - contents: |
        --- a/db/l3_db.py       2014-07-10 12:27:57.230986451 +0200
        +++ b/db/l3_db.py       2014-07-03 15:15:52.438764715 +0200
        @@ -614,6 +614,10 @@
                     msg = _("Network %s is not a valid external network") % f_net_id
                     raise n_exc.BadRequest(resource='floatingip', msg=msg)

        +        floating_ip_address = fip['floating_ip_address']
        +        if floating_ip_address is not attributes.ATTR_NOT_SPECIFIED:
        +            floating_ip_address = [{'ip_address': floating_ip_address}]
        +
                 with context.session.begin(subtransactions=True):
                     # This external port is never exposed to the tenant.
                     # it is used purely for internal system and admin use when
        @@ -623,7 +627,7 @@
                         {'tenant_id': '',  # tenant intentionally not set
                          'network_id': f_net_id,
                          'mac_address': attributes.ATTR_NOT_SPECIFIED,
        -                 'fixed_ips': attributes.ATTR_NOT_SPECIFIED,
        +                 'fixed_ips': floating_ip_address,
                          'admin_state_up': True,
                          'device_id': fip_id,
                          'device_owner': DEVICE_OWNER_FLOATINGIP,



/srv/salt/openstack/neutron/files/ml2_rpc.diff:
  file.managed:
    - makedirs: True
    - file_mode: 755
    - contents: |
        149a150,152
        >                      'device_id': port.device_id,
        >                      'device_owner': port.device_owner,
        >                      'mac_address': port.mac_address,

/srv/salt/openstack/neutron/files/linuxbridge_neutron_agent.diff:
  file.managed:
    - makedirs: True
    - file_mode: 755
    - contents: |
        58c58
        < BRIDGE_FS = "/sys/devices/virtual/net/"
        ---
        > BRIDGE_FS = "/sys/class/net/"
        62a63
        > BRIDGE_FS_FOR_DEVICE = BRIDGE_PORT_FS_FOR_DEVICE + "/bridge"
        63a65,67
        > # Allow forwarding of all 802.1d frames but 0 and disallowed STP, LLDP
        > BRIDGE_FWD_MASK_FS = BRIDGE_FS + BRIDGE_NAME_PLACEHOLDER + "/bridge/group_fwd_mask"
        > BRIDGE_FWD_MASK = hex(0xffff ^ (1 << 0x0 | 1 << 0x1 | 1 << 0x2 | 1 << 0xe))
        91,106d94
        <     def device_exists(self, device):
        <         """Check if ethernet device exists."""
        <         try:
        <             utils.execute(['ip', 'link', 'show', 'dev', device],
        <                           root_helper=self.root_helper)
        <         except RuntimeError:
        <             return False
        <         return True
        <
        <     def interface_exists_on_bridge(self, bridge, interface):
        <         directory = '/sys/class/net/%s/brif' % bridge
        <         for filename in os.listdir(directory):
        <             if filename == interface:
        <                 return True
        <         return False
        <
        142a131,133
        >     def device_exists(self, device):
        >         return os.path.exists(BRIDGE_FS + device)
        >
        166c157
        <     def get_bridge_for_tap_device(self, tap_device_name):
        ---
        >     def get_bridge_for_device(self, device_name):
        168,169c159,161
        <             br_path = os.path.join(BRIDGE_FS, tap_device_name, 'master')
        <             return os.path.basename(os.readlink(br_path))
        ---
        >             bridge_link_path = BRIDGE_FS_FOR_DEVICE.replace(
        >                 DEVICE_NAME_PLACEHOLDER, device_name)
        >             return os.path.basename(os.readlink(bridge_link_path))
        172,178d163
        <         bridges = self.get_all_neutron_bridges()
        <         for bridge in bridges:
        <             interfaces = self.get_interfaces_on_bridge(bridge)
        <             if tap_device_name in interfaces:
        <                 return bridge
        <
        <         return None
        311,313d295
        <             if utils.execute(['brctl', 'stp', bridge_name,
        <                               'off'], root_helper=self.root_helper):
        <                 return
        320a303,314
        >         # Forward all available multicast frames prohibited by 802.1d
        >         bridge_mask_path = BRIDGE_FWD_MASK_FS.replace(
        >                                BRIDGE_NAME_PLACEHOLDER, bridge_name)
        >         # Do not turn off STP for maximum transparency
        >         if utils.execute(['brctl', 'stp', bridge_name,
        >                           'on'], root_helper=self.root_helper):
        >             LOG.warning('Failed to enable STP on bridge %s', bridge_name)
        >         if utils.execute(['tee', bridge_mask_path],
        >                          process_input=BRIDGE_FWD_MASK,
        >                          root_helper=self.root_helper) != BRIDGE_FWD_MASK:
        >             LOG.warning('Failed to unmask group forwarding on bridge %s',
        >                         bridge_name)
        328c322,323
        <         if not self.interface_exists_on_bridge(bridge_name, interface):
        ---
        >         bridge = self.get_bridge_for_device(interface)
        >         if bridge != bridge_name:
        331,332c326
        <                 if self.is_device_on_bridge(interface):
        <                     bridge = self.get_bridge_for_tap_device(interface)
        ---
        >                 if bridge is not None:
        398,399c392,393
        <         tap_device_in_bridge = self.get_bridge_for_tap_device(tap_device_name)
        <         if not tap_device_in_bridge:
        ---
        >         in_bridge = self.get_bridge_for_device(tap_device_name)
        >         if in_bridge != bridge_name:
        404a399,401
        >             if in_bridge and utils.execute(['brctl', 'delif', in_bridge, tap_device_name],
        >                                            root_helper=self.root_helper):
        >                 return False
        511a509,528
        >     def update_device_link(self, port_id, node_id, hw_addr, owner, state):
        >         """Set link state of interface based on admin state in libvirt/kvm"""
        >         if not owner or not owner.startswith('compute:'):
        >             return None
        >         if not hw_addr or not node_id:
        >             return False
        >
        >         state = 'up' if state else 'down'
        >         LOG.debug('Bringing port %s with %s of node %s %s',
        >                   port_id, hw_addr, node_id, state)
        >         try:
        >             utils.execute(['virsh', 'domif-setlink', '--domain', node_id,
        >                            '--interface', hw_addr, '--state', state],
        >                           root_helper=self.root_helper)
        >             return True
        >         except RuntimeError:
        >             LOG.exception('Failed to update port %s of node %s mac %s to %s',
        >                           port_id, node_id, hw_addr, state)
        >             return False
        >
        689a707,712
        >             LOG.warning('Update of port %s' % port)
        >             updown = self.agent.br_mgr.update_device_link(port_id=port['id'],
        >                                                           node_id=port.get('device_id'),
        >                                                           hw_addr=port.get('mac_address'),
        >                                                           owner=port.get('device_owner'),
        >                                                           state=port['admin_state_up'])
        930a954,958
        >                 updown = self.br_mgr.update_device_link(port_id=details['port_id'],
        >                                                         node_id=details.get('device_id'),
        >                                                         hw_addr=details.get('mac_address'),
        >                                                         owner=details.get('device_owner'),
        >                                                         state=details['admin_state_up'])

/etc/neutron/rootwrap.d/linuxbridge-plugin.filters:
  file.append:
    - require:
      - pkg: neutron-pkgs
    - text: |
        virsh: CommandFilter, virsh, root
        tee: CommandFilter, tee, root

/usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/lb_neutron_plugin.py:
  file.patch:
    - source: file:///srv/salt/openstack/neutron/files/lb_neutron_plugin.py.diff
    - hash: md5=7560254626099a5dec158518f47b2d87
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/lb_neutron_plugin.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/lb_neutron_plugin.py
    - require:
      - pkg: neutron-pkgs
      - file: /srv/salt/openstack/neutron/files/lb_neutron_plugin.py.diff


/usr/lib/python2.7/dist-packages/neutron/plugins/ml2/rpc.py:
  file.patch:
    - source: file:///srv/salt/openstack/neutron/files/ml2_rpc.diff
    - hash: md5=23ab68a470d8b1a2223e0f495dc21837
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/plugins/ml2/rpc.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/plugins/ml2/rpc.py
    - require:
      - pkg: neutron-pkgs
      - file: /srv/salt/openstack/neutron/files/ml2_rpc.diff


linuxbridge_neutron_agent:
  file.managed:
    - source: file:///srv/salt/openstack/neutron/files/linuxbridge_neutron_agent.py
    - name: /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py
    - onfail:
      - file: linuxbridge_neutron_agent patch

compile linuxbridge:
  cmd.run:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py
    - onchanges:
      - file: linuxbridge_neutron_agent patch
      - file: linuxbridge_neutron_agent

linuxbridge_neutron_agent patch:
  file.patch:
    - name: /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py
    - source: file:///srv/salt/openstack/neutron/files/linuxbridge_neutron_agent.diff
    - hash: md5=36394295c3835838af8d0c63d072d513
    - require:
      - pkg: neutron-pkgs
      - file: /srv/salt/openstack/neutron/files/linuxbridge_neutron_agent.diff

/usr/lib/python2.7/dist-packages/neutron/extensions/l3.py:
  file.patch:
    - source: file:///srv/salt/openstack/neutron/files/l3.py.diff
    - hash: md5=3739e6a7463a3e2102b76d1cc3ebeff6
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/extensions/l3.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/extensions/l3.py
      - require:
        - pkg: neutron-pkgs
        - file: /srv/salt/openstack/neutron/files/l3.py.diff


/usr/lib/python2.7/dist-packages/neutron/db/l3_db.py:
  file.patch:
    - source: file:///srv/salt/openstack/neutron/files/l3_db.diff
    - hash: md5=c99c80ba6aa209fcd046a972af51a914
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/neutron/db/l3_db.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/neutron/db/l3_db.py
      - require:
        - pkg: neutron-pkgs
        - file: /srv/salt/openstack/neutron/files/l3_db.diff



linuxbridge hold:
  apt.held:
    - name: neutron-plugin-linuxbridge-agent
    - require:
      - pkg: neutron-pkgs

neutron restart:
  cmd.run:
    - order: last
    - name: 'service neutron-server restart'

neutron sysctl:
  cmd.run:
    - name: 'sysctl -p'
    - onchanges:
      - file: /etc/sysctl.conf
