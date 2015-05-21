{% set dist_upgrade = salt['pillar.get']('virl:dist_upgrade', salt['grains.get']('dist_upgrade', True)) %}

include:
  - common.kvm

dist upgrade host:
  module.run:
    - name: pkg.upgrade
    - refresh: True
    - dist_upgrade: {{ dist_upgrade }}

apt cleanup:
  cmd.wait:
    - name: apt-get autoremove -y
    - onchanges:
      - module: dist upgrade host
