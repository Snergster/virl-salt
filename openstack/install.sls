{% set horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', false)) %}
{% set cinder = salt['pillar.get']('virl:enable_cinder', salt['grains.get']('enable_cinder', false)) %}
{% set heat = salt['pillar.get']('virl:enable_heat', salt['grains.get']('enable_heat', false)) %}

include:
  - openstack.repo
  - openstack.mysql
  - openstack.rabbitmq
  - openstack.keystone
  - openstack.osclients
  - openstack.glance
  - openstack.neutron
  - openstack.nova
{% if horizon %}
  - openstack.dash
{% endif %}
{% if cinder %}
  - openstack.cinder
{% endif %}
{% if heat %}
  - openstack.heat
{% endif %}
  - openstack.restart
  
