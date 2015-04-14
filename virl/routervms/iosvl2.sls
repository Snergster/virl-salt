
{% set iosvl2 = salt['pillar.get']('routervms:iosvl2', False ) %}
{% set iosvl2pref = salt['pillar.get']('virl:iosvl2', salt['grains.get']('iosvl2', True)) %}
{% if iosvl2 and iosvl2pref %}

IOSvL2:
  glance.image_present:
    - profile: virl
    - name: 'IOSvL2'
    - container_format: bare
    - min_disk: 2
    - min_ram: 0
    - is_public: True
    - checksum: 126920bd9a0d67f533ba8dc359a3e306
    - protected: False
    - disk_format: qcow2
    - copy_from: salt://images/salt/vios_l2-adventerprisek9-m.qcow2
    - property-config_disk_type: disk
    - property-hw_cdrom_type: ide
    - property-hw_disk_bus: virtio
    - property-hw_vif_model: e1000
    - property-release: 15.2.411
    - property-serial: 2
    - property-subtype: IOSv

IOSvL2 flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "IOSvL2"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "IOSvL2"
    - onchanges:
      - glance: IOSvL2

IOSvL2 flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOSvL2'
    - ram: 512
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: IOSvL2
    - require:
      - cmd: IOSvL2 flavor delete

{% else %}

IOSvL2 gone:
  glance.image_absent:
  - profile: virl
  - name: 'IOSvL2'

IOSvL2 flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "IOSvL2"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "IOSvL2"
{% endif %}
