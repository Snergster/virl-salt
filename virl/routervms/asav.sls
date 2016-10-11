{% set asav = salt['pillar.get']('routervms:asav', False) %}
{% set asavpref = salt['pillar.get']('virl:asav', salt['grains.get']('asav', True)) %}

include:
  - virl.routervms.virl-core-sync

{% if asav and asavpref %}
asav:
  glance.image_present:
    - profile: virl
    - name: 'ASAv'
    - container_format: bare
    - min_disk: 9
    - min_ram: 0
    - is_public: True
    - checksum: 73a1126283de6b70c4cc12edfc46d547
    - protected: False
    - disk_format: qcow2
    - copy_from: salt://images/salt/asav952-204.qcow2
    - property-config_disk_type: cdrom
    - property-hw_cdrom_bus: ide
    - property-hw_disk_bus: ide
    - property-hw_vif_model: e1000
    - property-release: 9.5.2-204
    - property-serial: 1
    - property-subtype: ASAv

asav flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "ASAv"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "ASAv"
    - onchanges:
      - glance: asav

asav flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'ASAv'
    - ram: 2048
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: asav
    - require:
      - cmd: asav flavor delete

{% else %}

asav gone:
  glance.image_absent:
  - profile: virl
  - name: 'ASAv'

asav flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "ASAv"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "ASAv"
{% endif %}
