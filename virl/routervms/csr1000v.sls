{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

{% if virl.csr1000v and virl.csr1000vpref %}
CSR1000v:
  glance.image_present:
  - profile: virl
  - name: 'CSR1000v'
  - container_format: bare
  - min_disk: 8
  - min_ram: 0
  - is_public: True
  - checksum: a770e96de928265515304c9c9d6b46b9
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/csr1000v-universalk9.16.3.1-ext-b2.qcow2
  - property-config_disk_type: cdrom
  - property-hw_cdrom_bus: ide
  - property-hw_disk_bus: virtio
  - property-hw_vif_model: virtio
  - property-release: 16.3.1-build2
  - property-serial: 2
  - property-subtype: CSR1000v

CSR1000v flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "CSR1000v"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "CSR1000v"
    - onchanges:
      - glance: CSR1000v

CSR1000v flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'CSR1000v'
    - ram: 3072
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: CSR1000v
    - require:
      - cmd: CSR1000v flavor delete

{% else %}

CSR1000v gone:
  glance.image_absent:
  - profile: virl
  - name: 'CSR1000v'

CSR1000v flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "CSR1000v"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "CSR1000v"
{% endif %}
