{% from "virl.jinja" import virl with context %}

include:
  - virl.openrc
{% if virl.controller %}
  - openstack.keystone.apache2
  - openstack.nova.keystone
  - openstack.neutron.changes
  - openstack.neutron.delete-basic
  - openstack.neutron.create-basic
  - openstack.cinder.create
{% endif %}
{% if virl.packet and virl.cluster %}
  - openstack.neutron.packet_cluster
{% endif %}
