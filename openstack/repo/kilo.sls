{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

kilo_base:
  pkgrepo.managed:
    - ppa: 'cloud-archive:kilo'
  module.run:
    - name: pkg.upgrade
    - refresh: True
    - dist_upgrade: False
