nova-conf-debug-on:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'debug'
    - value: ' True'

nova-conf-verbose-on:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'verbose'
    - value: ' True'

neutron-conf-debug-on:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'debug'
    - value: ' True'

neutron-conf-verbose-on:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'verbose'
    - value: ' True'

keystone-conf-debug-on:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'DEFAULT'
    - parameter: 'debug'
    - value: ' True'

keystone-conf-verbose-on:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'DEFAULT'
    - parameter: 'verbose'
    - value: ' True'

heat-conf-debug-on:
  openstack_config.present:
    - filename: /etc/heat/heat.conf
    - section: 'DEFAULT'
    - parameter: 'debug'
    - value: ' True'

heat-conf-verbose-on:
  openstack_config.present:
    - filename: /etc/heat/heat.conf
    - section: 'DEFAULT'
    - parameter: 'verbose'
    - value: ' True'

debugon-restart:
  cmd.run:
    - name: |
        service nova-cert restart
        service nova-api restart
        service nova-consoleauth restart
        service nova-scheduler restart
        service nova-conductor restart
        service nova-novncproxy restart
        service neutron-server restart
        service keystone restart
        service heat-api restart
        service heat-api-cfn restart
        service heat-engine restart


