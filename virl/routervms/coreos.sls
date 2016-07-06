{% set coreos = salt['pillar.get']('routervms:coreos', False) %}
{% set coreospref = salt['pillar.get']('virl:coreos', salt['grains.get']('coreos', True)) %}

{% if coreos and coreospref %}
coreos:
  glance.image_present:
    - profile: virl
    - name: 'coreos'
    - container_format: bare
    - min_disk: 9
    - min_ram: 0
    - is_public: True
    - checksum: 9b19d205a7274eb8fcba7bc5be723a91
    - protected: False
    - disk_format: qcow2
    - copy_from: salt://images/salt/coreos-899-13-0.qcow2
    - property-config_disk_type: cloud-init
    - property-hw_cdrom_type: ide
    - property-hw_disk_bus: ide
    - property-hw_vif_model: virtio
    - property-release: 899.13.0
    - property-serial: 1
    - property-subtype: CoreOS

coreos flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "coreos"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "coreos"
    - onchanges:
      - glance: coreos

coreos flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'coreos'
    - ram: 2048
    - disk: 0
    - vcpus: 2
    - onchanges:
      - glance: coreos
    - require:
      - cmd: coreos flavor delete

{% else %}

coreos gone:
  glance.image_absent:
  - profile: virl
  - name: 'coreos'

coreos flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "coreos"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "coreos"
{% endif %}
