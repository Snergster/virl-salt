{% set nxosv = salt['pillar.get']('routervms:nxosv', False) %}
{% set nxosvpref = salt['pillar.get']('virl:nxosv', salt['grains.get']('nxosv', True)) %}

include:
  - virl.routervms.virl-core-sync

{% if nxosv and nxosvpref %}

NX-OSv:
  glance.image_present:
  - profile: virl
  - name: 'NX-OSv'
  - container_format: bare
  - min_disk: 2
  - min_ram: 0
  - is_public: True
  - checksum: 0ee38c7d717840cb4ca822f4870671d0
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/titanium-d1.7.2.0.D1.1.vmdk
  - property-config_disk_type: cdrom
  - property-hw_cdrom_type: ide
  - property-hw_disk_bus: ide
  - property-hw_vif_model: e1000
  - property-release: 7.2.0.121
  - property-serial: 2
  - property-subtype: NX-OSv

NX-OSv flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "NX-OSv"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "NX-OSv"
    - require:
      - glance: NX-OSv

NX-OSv flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'NX-OSv'
    - ram: 3072
    - disk: 0
    - vcpus: 1
    - require:
      - cmd: NX-OSv flavor delete

{% else %}

NX-OSv gone:
  glance.image_absent:
  - profile: virl
  - name: 'NX-OSv'

NX-OSv flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "NX-OSv"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "NX-OSv"
{% endif %}
