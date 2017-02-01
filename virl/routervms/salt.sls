{% set vPP = salt['pillar.get']('routervms:vpp', True) %}
{% set vsaltpref = salt['pillar.get']('virl:vsalt', salt['grains.get']('vsalt', False)) %}

{% if vsaltpref %}

vsalt:
  glance.image_present:
  - profile: virl
  - name: 'vsalt'
  - container_format: bare
  - min_disk: 3
  - min_ram: 0
  - is_public: True
  - checksum: 3021da37dcdb6c58c7aeb2c088270e0a
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/private/salt.qcow2
  - property-hw_disk_bus: virtio
  - property-release: 0.4
  - property-serial: 1
  - property-subtype: server

vsalt flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "vsalt"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "vsalt"
    - onchanges:
      - glance: vsalt

vsalt flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'vsalt'
    - ram: 512
    - disk: 0
    - vcpus: 1
  {% if virl.mitaka %}
    - profile: virl
  {% endif %}
    - onchanges:
      - glance: vsalt
    - require:
      - cmd: vsalt flavor delete

vsalt flavor create2:
  module.run:
    - name: nova.flavor_create
    - m_name: 'vsalt'
    - profile: virl
    - ram: 512
    - disk: 0
    - vcpus: 1
    - onfail:
      - module: 'vsalt flavor create'

{% else %}

vsalt gone:
  glance.image_absent:
  - profile: virl
  - name: 'vsalt'

vsalt flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "vsalt"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "vsalt"
{% endif %}
