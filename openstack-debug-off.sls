nova-conf-debug-off:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'debug'
    - value: ' False'

nova-conf-verbose-off:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'verbose'
    - value: ' False'

neutron-conf-debug-off:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'debug'
    - value: ' False'

neutron-conf-verbose-off:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'verbose'
    - value: ' False'

keystone-conf-debug-off:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'DEFAULT'
    - parameter: 'debug'
    - value: ' False'

keystone-conf-verbose-off:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'DEFAULT'
    - parameter: 'verbose'
    - value: ' False'

heat-conf-debug-off:
  openstack_config.present:
    - filename: /etc/heat/heat.conf
    - section: 'DEFAULT'
    - parameter: 'debug'
    - value: ' False'

heat-conf-verbose-off:
  openstack_config.present:
    - filename: /etc/heat/heat.conf
    - section: 'DEFAULT'
    - parameter: 'verbose'
    - value: ' False'

debugoff-restart:
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
