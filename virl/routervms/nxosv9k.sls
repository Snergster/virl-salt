{% set nxosv9k = salt['pillar.get']('routervms:nxosv9k', False) %}
{% set nxosv9kpref = salt['pillar.get']('virl:nxosv9k', salt['grains.get']('nxosv9k', True)) %}

include:
  - virl.routervms.virl-core-sync
  - virl.efibios

{% if nxosv9k and nxosv9kpref %}

nxosv9k:
  glance.image_present:
  - profile: virl
  - name: 'NX-OSv 9000'
  - container_format: bare
  - min_disk: 2
  - min_ram: 0
  - is_public: True
  - checksum: feeb4f5bc3b7114cc2ba5b5475716f25
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/nxosv-final.7.0.3.I2.1.qcow2
  - property-config_disk_type: cdrom
  - property-hw_cdrom_type: ide
  - property-hw_disk_bus: ide
  - property-hw_vif_model: e1000
  - property-release: 7.0.3.I2.1
  - property-serial: 2
  - property-subtype: NX-OSv 9000

nxosv9k flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "NX-OSv 9000"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "NX-OSv 9000"
    - require:
      - glance: nxosv9k

nxosv9k flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'NX-OSv 9000'
    - ram: 12288
    - disk: 8192
    - vcpus: 4
    - require:
      - cmd: nxosv9k flavor delete

{% else %}

nxosv9k gone:
  glance.image_absent:
  - profile: virl
  - name: 'NX-OSv 9000'

nxosv9k flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "NX-OSv 9000"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "NX-OSv 9000"
{% endif %}
