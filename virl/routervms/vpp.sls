{% from "virl.jinja" import virl with context %}

{% if virl.vpp and virl.vpppref %}

vpp:
  glance.image_present:
  - profile: virl
  - name: 'vpp'
  - container_format: bare
  - min_disk: 4
  - min_ram: 0
  - is_public: True
  - checksum: d93fd5ae034b74b0524e0f12167b4049
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/private/vpp-vppDEV_07302015.qcow2
  - property-hw_disk_bus: virtio
  - property-release: 07302015
  - property-serial: 1
  - property-subtype: vpp

vpp flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "vpp"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "vpp"
    - onchanges:
      - glance: vpp

vpp flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'vpp'
    - ram: 2048
    - disk: 0
    - vcpus: 2
  {% if virl.mitaka %}
    - profile: virl
  {% endif %}
    - onchanges:
      - glance: vpp
    - require:
      - cmd: vpp flavor delete

{% else %}

vpp gone:
  glance.image_absent:
  - profile: virl
  - name: 'vpp'

vpp flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "vpp"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "vpp"
{% endif %}
