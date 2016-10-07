{% set dist_upgrade = salt['pillar.get']('virl:dist_upgrade', salt['grains.get']('dist_upgrade', True)) %}

{% if not 'xenial' in salt['grains.get']('oscodename') %}
include:
  - common.kvm
{% endif %}

salt to trusted:
  file.replace:
    - name: /etc/apt/sources.list.d/saltstack.list
    - pattern: deb https
    - repl: deb [trusted=yes] https


dist upgrade host:
  module.run:
    - name: pkg.upgrade
    - refresh: True
    - dist_upgrade: {{ dist_upgrade }}

