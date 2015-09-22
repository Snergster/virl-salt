{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

kilo_base:
  cmd.run:
    - name: 'apt-add-repository cloud-archive:kilo -y'
  module.run:
    - name: pkg.upgrade
    - refresh: True
    - dist_upgrade: False
    - require:
      - cmd: kilo_base
