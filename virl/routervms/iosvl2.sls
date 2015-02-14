
{% set iosvl2 = salt['pillar.get']('routervms:iosvl2', False ) %}
{% set iosvl2pref = salt['pillar.get']('virl:iosvl2', salt['grains.get']('iosvl2', True)) %}
{% if iosvl2 and iosvl2pref %}

IOSvl2:
  glance.image_present:
    - profile: virl
    - name: 'IOSvl2'
    - container_format: bare
    - min_disk: 0
    - min_ram: 0
    - is_public: True
    - checksum: cc24763225f7cbab7b3cef997558ecab
    - protected: False
    - disk_format: qcow2
    - copy_from: salt://images/salt/vios_l2-adventerprisek9-m.qcow2
    - property-config_disk_type: disk
    - property-hw_cdrom_type: ide
    - property-hw_disk_bus: virtio
    - property-hw_vif_model: e1000
    - property-release: 15.4.3.M
    - property-serial: 2
    - property-subtype: IOSv

iosvl2 flavor delete:
  cmd.run:
    - name: 'nova flavor-delete "IOSvl2"'
    - onlyif: nova flavor-list | grep -w "IOSvl2"
    - onchanges:
      - glance: IOSvl2

IOSvl2 flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOSvl2'
    - ram: 512
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: IOSvl2
    - require:
      - cmd: IOSvl2 flavor delete

{% else %}

IOSvl2 gone:
  glance.image_absent:
  - profile: virl
  - name: 'IOSvl2'

IOSvl2 flavor absent:
  cmd.run:
    - name: 'nova flavor-delete "IOSvl2"'
    - onlyif: nova flavor-list | grep -w "IOSvl2"
{% endif %}
