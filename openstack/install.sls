{% set horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', false)) %}
{% set cinder = salt['pillar.get']('virl:enable_cinder', salt['grains.get']('enable_cinder', false)) %}
{% set heat = salt['pillar.get']('virl:enable_heat', salt['grains.get']('enable_heat', false)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', true)) %}

include:
  - openstack.repo.kilo
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
{% else %}
  - openstack.cinder.off
{% endif %}
{% if heat %}
  - openstack.heat
{% endif %}
  - openstack.restart
  
