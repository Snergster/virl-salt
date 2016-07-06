
{% set iosvl2 = salt['pillar.get']('routervms:iosvl2', False ) %}
{% set iosvl2pref = salt['pillar.get']('virl:iosvl2', salt['grains.get']('iosvl2', True)) %}
{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}
{% set cml_iosvl2 = salt['pillar.get']('virl:cml_iosvl2', salt['grains.get']('cml_iosvl2', False )) %}

include:
  - virl.routervms.virl-core-sync

{% if iosvl2pref or cml_iosvl2 %}

IOSvL2:
  glance.image_present:
    - profile: virl
    - name: 'IOSvL2'
    - container_format: bare
    - min_disk: 2
    - min_ram: 0
    - is_public: True
    - protected: False
    - disk_format: qcow2
{% if cml %}
    - checksum: c9d556c75a3aa510443014c5dea3dbdb
    - copy_from: salt://images/salt/vios_l2-adventerprisek9-m.cml.vmdk
    - property-release: 15.2.4063
{% else %}
    - checksum: 1a3a21f5697cae64bb930895b986d71e
    - copy_from: salt://images/salt/vios_l2-adventerprisek9-m.vmdk.SSA.152-4.0.55.E
    - property-release: 15.2.4055
{% endif %}
    - property-config_disk_type: disk
    - property-hw_cdrom_type: ide
    - property-hw_disk_bus: virtio
    - property-hw_vif_model: e1000
    - property-serial: 2
    - property-subtype: IOSvL2

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
    - ram: 768
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
