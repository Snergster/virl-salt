{% set nxosv = salt['pillar.get']('routervms:nxosv', False) %}
{% set nxosvpref = salt['pillar.get']('virl:nxosv', salt['grains.get']('nxosv', True)) %}

{% if nxosv and nxosvpref %}

NX-OSv:
  glance.image_present:
  - profile: virl
  - name: 'NX-OSv'
  - container_format: bare
  - min_disk: 0
  - min_ram: 0
  - is_public: True
  - checksum: 9d76757de080434d8b70983b477c09aa
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/titanium-final.7.2.0.ZD.0.120.qcow2
  - property-config_disk_type: cdrom
  - property-hw_cdrom_type: ide
  - property-hw_disk_bus: ide
  - property-hw_vif_model: e1000
  - property-release: 7.2.0.120
  - property-serial: 2
  - property-subtype: NX-OSv

NX-OSv flavor delete:
  cmd.run:
    - name: 'nova flavor-delete "NX-OSv"'
    - onlyif: nova flavor-show "NX-OSv"
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
    - name: 'nova flavor-delete "NX-OSv"'
    - onlyif: nova flavor-list | grep -w "NX-OSv"
{% endif %}
