{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}


{% if packet %}
update sourcelist to include packet sources:
  file.append:
    - name: /etc/apt/sources.list
    - text:
      - 'deb [arch=amd64] ftp://147.75.194.83/ubuntu trusty-updates/kilo main'
  cmd.run:
    - name: 'apt-get update -qq'
    - onchanges:
      - file: update sourcelist to include packet sources
{% endif %}

kilo_base:
  cmd.run:
    - name: 'apt-add-repository cloud-archive:kilo -y'
  module.run:
    - name: pkg.upgrade
    - refresh: True
    - dist_upgrade: False
    - require:
      - cmd: kilo_base
