{% set iscontroller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True)) %}

include:
  - virl.openrc
  - openstack.nova.keystone
  - openstack.neutron.changes
{% if iscontroller %}
  - openstack.neutron.create-basic
  - openstack.cinder.create
{% endif %}
