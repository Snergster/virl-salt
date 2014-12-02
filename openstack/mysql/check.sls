{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_IP', '172.16.10.250')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}

mysql port check:
  openstack_config.present:
    - filename: /etc/mysql/my.cnf
    - section: 'mysqld'
    - parameter: 'bind-address'
    - value: '{{ controllerip }}'

check cinder-conn:
  openstack_config.present:
    - filename: /etc/cinder/cinder.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://cinder:{{ mypassword }}@{{ controllerip }}/cinder'

check glance-api-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ mypassword }}@{{ controllerip }}/glance'

check glance-reg-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ mypassword }}@{{ controllerip }}/glance'

check heat-conn:
  openstack_config.present:
    - filename: /etc/heat/heat.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://heat:{{ mypassword }}@{{ controllerip }}/heat'

check neutron-plugin-conn:
  openstack_config.present:
    - filename: /etc/neutron/plugins/ml2/ml2_conf.ini
    - section: 'database'
    - parameter: 'sql_connection'
    - value: 'mysql://neutron:{{ mypassword }}@{{ controllerip }}/neutron'

check neutron-conn:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://neutron:{{ mypassword }}@{{ controllerip }}/neutron'

check /etc/keystone/keystone.conf:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'database'
    - parameter: 'connection'
    - value: ' mysql://keystone:{{ mypassword }}@{{ controllerip }}/keystone'
