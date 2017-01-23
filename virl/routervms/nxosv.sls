{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

{% if virl.nxosv and virl.nxosvpref %}

NX-OSv:
  glance.image_present:
  - profile: virl
  - name: 'NX-OSv'
  - container_format: bare
  - min_disk: 2
  - min_ram: 0
  - is_public: True
  - checksum: b4cd6edf15ab4c6bce53c3f6c1e3a742
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/titanium-final.7.3.0.D1.1.qcow2
  - property-config_disk_type: cdrom
  - property-hw_cdrom_bus: ide
  - property-hw_disk_bus: ide
  - property-hw_vif_model: e1000
  - property-release: 7.3.0.1
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
  {% if virl.mitaka %}
    - profile: virl
  {% endif %}
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
