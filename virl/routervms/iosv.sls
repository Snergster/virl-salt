{% set iosv = salt['pillar.get']('routervms:iosv', False ) %}
{% set iosvpref = salt['pillar.get']('virl:iosv', salt['grains.get']('iosv', True)) %}
{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}

{% if iosv and iosvpref %}

iosv:
  glance.image_present:
    - profile: virl
    - name: 'IOSv'
    - container_format: bare
    - min_disk: 0
    - min_ram: 0
    - is_public: True
  {% if cml %}
    - checksum: a59dd80377d4d7f066c1c1f02971a248
    - copy_from: salt://images/salt/vios-adventerprisek9-m.155-2.T.qcow2
  {% else %}
    - checksum: 8d448fe4d202f4d9da81fad0f2a6bb9b
    - copy_from: salt://images/salt/vios-adventerprisek9-m.cml.qcow2
  {% endif %}
    - protected: False
    - disk_format: qcow2
    - property-config_disk_type: disk
    - property-hw_cdrom_type: ide
    - property-hw_disk_bus: virtio
    - property-hw_vif_model: e1000
    - property-release: 15.5.2.M
    - property-serial: 2
    - property-subtype: IOSv

iosv flavor delete:
  cmd.run:
    - name: 'nova flavor-delete "IOSv"'
    - onlyif: nova flavor-show "IOSv"
    - onchanges:
      - glance: iosv

iosv flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOSv'
    - ram: 512
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: iosv
    - require:
      - cmd: iosv flavor delete

{% else %}

iosv gone:
  glance.image_absent:
  - profile: virl
  - name: 'IOSv'

iosv flavor absent:
  cmd.run:
    - name: 'nova flavor-delete "IOSv"'
    - onlyif: nova flavor-list | grep -w "IOSv"
{% endif %}
