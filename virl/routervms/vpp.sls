{% set vPP = salt['pillar.get']('routervms:vpp', True) %}
{% set vPPpref = salt['pillar.get']('virl:vpp', salt['grains.get']('vpp', True)) %}

{% if vPP and vPPpref %}

vPP:
  glance.image_present:
  - profile: virl
  - name: 'vPP'
  - container_format: bare
  - min_disk: 4
  - min_ram: 0
  - is_public: True
  - checksum: d93fd5ae034b74b0524e0f12167b4049
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/private/vpp-VPPDEV_07302015.qcow2
  - property-hw_disk_bus: virtio
  - property-release: 07302015
  - property-serial: 1
  - property-subtype: vPP

vPP flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "vPP"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "vPP"
    - onchanges:
      - glance: vPP

vPP flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'vPP'
    - ram: 2048
    - disk: 0
    - vcpus: 2
    - onchanges:
      - glance: vPP
    - require:
      - cmd: vPP flavor delete

{% else %}

vPP gone:
  glance.image_absent:
  - profile: virl
  - name: 'vPP'

vPP flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "vPP"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "vPP"
{% endif %}
