{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', true)) %}
{% set mitaka = salt['pillar.get']('virl:mitaka', salt['grains.get']('mitaka', false)) %}

include:
{% if kilo %}
  - openstack.repo.kilo
{% endif %}
{% if mitaka %}
  - openstack.repo.mitaka
{% endif %}
