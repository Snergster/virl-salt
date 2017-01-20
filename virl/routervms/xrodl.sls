
iosxrv:
  glance.image_present:
  - profile: virl
  - name: 'IOS XRv'
  - container_format: bare
  - min_disk: 4
  - min_ram: 0
  - is_public: True
  - checksum: 139eade5e9667f127f95082a18e4e30c
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/iosxrv-5.3.2-11-i2ss.qcow2
  - property-config_disk_type: cdrom
  - property-hw_cdrom_bus: ide
  - property-hw_disk_bus: ide
  - property-hw_vif_model: virtio
  - property-release: 5.3.2
  - property-serial: 3
  - property-subtype: 'IOS XRv'


iosxrv flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "IOS XRv"'
    - onlyif: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-show "IOS XRv"'
    - onchanges:
      - glance: iosxrv

iosxrv flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOS XRv'
    - ram: 3096
    - disk: 0
    - vcpus: 1
  {% if virl.mitaka %}
    - profile: virl
  {% endif %}
    - onchanges:
      - glance: iosxrv
    - require:
      - cmd: iosxrv flavor delete

iosxrv flavor create2:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOS XRv'
    - profile: virl
    - ram: 3096
    - disk: 0
    - vcpus: 1
    - onfail:
      - module: 'iosxrv flavor create'
