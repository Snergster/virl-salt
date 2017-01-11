{% if not 'xenial' in salt['grains.get']('oscodename') %}
include:
  - openstack.repo.kilo
  {% endif %}
