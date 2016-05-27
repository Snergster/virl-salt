{% set dist_upgrade = salt['pillar.get']('virl:dist_upgrade', salt['grains.get']('dist_upgrade', True)) %}

include:
  - common.kvm
  - common.salt-minion.salt-version-lock

dist upgrade host:
  module.run:
    - name: pkg.upgrade
    - refresh: True
    - dist_upgrade: {{ dist_upgrade }}

{% if '2015' in salt['grains.get']('saltversion') %}

apt cleanup:
  module.run:
    - name: pkg.autoremove

{% else %}

apt cleanup:
  cmd.run:
    - name: apt-get autoremove -y
    - onchanges:
      - module: dist upgrade host
{% endif %}
