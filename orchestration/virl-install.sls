install_mysql:
  salt.state:
    - tgt: 'ejkbootie.virl.qa'
    - sls:
      - openstack.mysql

install_rabbitmq:
  salt.state:
    - tgt: 'ejkbootie.virl.qa'
    - sls:
      - openstack.rabbitmq

install_keystone:
  salt.state:
    - tgt: 'ejkbootie.virl.qa'
    - sls:
      - openstack.keystone.install
      - openstack.keystone.setup

install_keystone-setup:
  salt.state:
    - tgt: 'ejkbootie.virl.qa'
    - sls:
      - openstack.keystone.setup

finish endpoints:
  salt.state:
    - tgt: 'ejkbootie.virl.qa'
    - sls:
      - openstack.keystone.endpoint

second grains in place:
  salt.function:
    - tgt: 'ejkbootie.virl.qa'
    - name: cmd.run
    - arg:
      - /usr/local/bin/vinstall salt

rest of second:
  salt.state:
    - tgt: 'ejkbootie.virl.qa'
    - sls:
      - openstack.keystone.endpoint
      - openstack.osclients
      - virl.openrc
      - openstack.glance
      - openstack.neutron.install
      - openstack.nova.install
      - openstack.neutron.changes

vinstall third:
  salt.function:
    - tgt: 'ejkbootie.virl.qa'
    - name: cmd.run
    - arg:
      - /usr/local/bin/vinstall third

virl services:
  salt.state:
    - tgt: 'ejkbootie.virl.qa'
    - sls:
      - virl.std
      - virl.guest
      - virl.ank
      - virl.routervms

## we want the below once desktop has big if
## also needed in tightvncserver,cinder and dash
##virl services:
##  salt.state:
##    - tgt: 'ejkbootie.virl.qa'
##    - sls:
##      - virl.desktop
