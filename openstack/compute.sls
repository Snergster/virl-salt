{% from "virl.jinja" import virl with context %}

include:
  - openstack.repo
  - virl.ntp
  - common.ifb
  - openstack.nova.compute
  - openstack.neutron.compute
  - openstack.setup
  - virl.std.tap-counter
  - openstack.restart
  - openstack.compute-key
  - common.salt-minion.running
  - common.bridge
