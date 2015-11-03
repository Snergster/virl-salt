
UbuntuServertrusty:
  glance.image_present:
  - profile: virl
  - name: 'odlcontroller'
  - container_format: bare
  - min_disk: 3
  - min_ram: 0
  - is_public: True
  - checksum: 7ce88b64d08848297746e07ab775e800
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/ODL-Bootcamp-VM.qcow2
  - property-hw_disk_bus: virtio
  - property-release: 14.04.2
  - property-serial: 1
  - property-subtype: server

UbuntuServertrusty flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "odlcontroller"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "odlcontroller"
    - onchanges:
      - glance: UbuntuServertrusty

UbuntuServertrusty flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'odlcontroller'
    - ram: 4096
    - disk: 0
    - vcpus: 2
    - onchanges:
      - glance: UbuntuServertrusty
    - require:
      - cmd: UbuntuServertrusty flavor delete

