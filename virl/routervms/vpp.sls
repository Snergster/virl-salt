{% set vPP = salt['pillar.get']('routervms:vpp', True) %}
{% set vPPpref = salt['pillar.get']('virl:vpp', salt['grains.get']('vpp', True)) %}

{% if vPP and vPPpref %}

vPP:
  glance.image_present:
  - profile: virl
  - name: 'vPP'
  - container_format: bare
  - min_disk: 0
  - min_ram: 0
  - is_public: True
  - checksum: 7dc139fa8540105c33c3c2b4fc3d6949
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/vpp-demo-PHASE2_03_25_2015.qcow2
  - property-hw_disk_bus: virtio
  - property-release: PHASE2_03_25_2015
  - property-serial: 1
  - property-subtype: vPP

vPP flavor delete:
  cmd.run:
    - name: 'nova flavor-delete "vPP"'
    - onlyif: nova flavor-list | grep -w "vPP"
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
    - name: 'nova flavor-delete "vPP"'
    - onlyif: nova flavor-list | grep -w "vPP"
{% endif %}
