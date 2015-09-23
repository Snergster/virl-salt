{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}

include:
  {% if not kilo %}
  - common.pip-conflicts
  {% endif %}
  - virl.openrc
  - openstack.nova.keystone
  - openstack.neutron.changes
  - openstack.neutron.create-basic
  - openstack.cinder.create
  
