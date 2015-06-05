{% set vPP = salt['pillar.get']('routervms:vpp', True) %}
{% set vsaltpref = salt['pillar.get']('virl:vsalt', salt['grains.get']('vsalt', False)) %}

{% if vsaltpref %}

vsalte:
  glance.image_present:
  - profile: virl
  - name: 'vsalte'
  - container_format: bare
  - min_disk: 3
  - min_ram: 0
  - is_public: True
  - checksum: 52aa5d45bd18ec8a847a33f595f7328d
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/private/salte.qcow2
  - property-hw_disk_bus: virtio
  - property-release: 0.4
  - property-serial: 1
  - property-subtype: server

vsalte flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "vsalte"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "vsalte"
    - onchanges:
      - glance: vsalte

vsalte flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'vsalte'
    - ram: 1024
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: vsalte
    - require:
      - cmd: vsalte flavor delete

{% else %}

vsalte gone:
  glance.image_absent:
  - profile: virl
  - name: 'vsalte'

vsalt flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "vsalte"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "vsalte"
{% endif %}
