{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

{% if virl.nxosv9k and virl.nxosv9kpref %}
nxosv9k:
  glance.image_present:
  - profile: virl
  - name: 'nxosv9k'
  - container_format: bare
  - min_disk: 8
  - min_ram: 0
  - is_public: True
  - checksum: cd24a021a0e908d36155b458f08a8e33
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/nxosv-final.7.0.3.I5.0.219.qcow2
  - property-config_disk_type: cdrom
  - property-hw_cdrom_type: sata
  - property-hw_disk_bus: virtio
  - property-hw_vif_model: virtio
  - property-release: nxosv-7.0.3.I5.0.219
  - property-serial: 2
  - property-subtype: nxosv9k

nxosv9k flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "nxosv9k"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "nxosv9k"
    - onchanges:
      - glance: nxosv9k

nxosv9k flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'nxosv9k'
    - ram: 8192
    - disk: 0
    - vcpus: 2
    - onchanges:
      - glance: nxosv9k
    - require:
      - cmd: nxosv9k flavor delete

{% else %}

nxosv9k gone:
  glance.image_absent:
  - profile: virl
  - name: 'nxosv9k'

nxosv9k flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "nxosv9k"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "nxosv9k"
{% endif %}
