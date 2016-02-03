{% set iscontroller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True)) %}
{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}
{% set virl_cluster = salt['pillar.get']('virl:virl_cluster', salt['grains.get']('virl_cluster', False))%}

include:
  - virl.openrc
{% if iscontroller %}
  - openstack.nova.keystone
  - openstack.neutron.changes
  - openstack.neutron.create-basic
  - openstack.cinder.create
{% endif %}
{% if packet and virl_cluster %}
  - openstack.neutron.packet_cluster
{% endif %}
