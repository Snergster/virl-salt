{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync
  - virl.efibios

{% if virl.nxosv9k and virl.nxosv9kpref %}
NX-OSv 9000:
  glance.image_present:
  - profile: virl
  - name: 'NX-OSv 9000'
  - container_format: bare
  - min_disk: 8
  - min_ram: 0
  - is_public: True
  - checksum: dac812fa61dc5d0307548f1cb515cd38
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/nxosv-final.7.0.3.I5.1.qcow2
  - property-config_disk_type: cdrom
  - property-hw_cdrom_bus: sata
  - property-hw_disk_bus: sata
  - property-hw_bios: n9kbios.bin
  - property-hw_vif_model: e1000
  - property-release: nxosv-7.0.3.I5.1
  - property-serial: 2
  - property-subtype: 'NX-OSv 9000'

NX-OSv 9000 flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "NX-OSv 9000"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "NX-OSv 9000"
    - onchanges:
      - glance: NX-OSv 9000

NX-OSv 9000 flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'NX-OSv 9000'
    - ram: 8192
    - disk: 0
    - vcpus: 2
    - onchanges:
      - glance: NX-OSv 9000
    - require:
      - cmd: NX-OSv 9000 flavor delete

NX-OSv 9000 flavor create2:
  module.run:
    - name: nova.flavor_create
    - m_name: 'NX-OSv 9000'
    - profile: virl
    - ram: 8192
    - disk: 0
    - vcpus: 2
    - onfail:
      - module: 'NX-OSv 9000 flavor create'

{% else %}

NX-OSv 9000 gone:
  glance.image_absent:
  - profile: virl
  - name: 'NX-OSv 9000'

NX-OSv 9000 flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "NX-OSv 9000"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "NX-OSv 9000"
{% endif %}