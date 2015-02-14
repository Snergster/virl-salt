{% set iosv = salt['pillar.get']('routervms:iosv', False ) %}
{% set iosvpref = salt['pillar.get']('virl:iosv', salt['grains.get']('iosv', True)) %}

{% if iosv and iosvpref %}

iosv:
  glance.image_present:
    - profile: virl
    - name: 'IOSv'
    - container_format: bare
    - min_disk: 0
    - min_ram: 0
    - is_public: True
    - checksum: 59c38ef98912f6e319142ee896b5b593
    - protected: False
    - disk_format: qcow2
    - copy_from: salt://images/salt/vios-adventerprisek9-m-15.4.3M.qcow2
    - property-config_disk_type: disk
    - property-hw_cdrom_type: ide
    - property-hw_disk_bus: virtio
    - property-hw_vif_model: e1000
    - property-release: 15.4.3.M
    - property-serial: 2
    - property-subtype: IOSv

iosv flavor delete:
  cmd.run:
    - name: 'nova flavor-delete "IOSv"'
    - onlyif: nova flavor-list | grep -w "IOSv"
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
