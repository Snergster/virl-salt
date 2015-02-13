{% set server = salt['pillar.get']('routervms:UbuntuServertrusty', True) %}
{% set serverpref = salt['pillar.get']('virl:server', salt['grains.get']('server', True)) %}

{% if server and serverpref %}

UbuntuServertrusty:
  glance.image_present:
  - profile: virl
  - name: 'server'
  - container_format: bare
  - min_disk: 0
  - min_ram: 0
  - is_public: True
  - checksum: 3b75214936278965eb716449733b105b
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/trusty-server-cloudimg-amd64-disk1.img
  - property-config_disk_type: cdrom
  - property-hw_disk_bus: virtio
  - property-release: 14.04
  - property-serial: 1
  - property-subtype: server

UbuntuServertrusty flavor delete:
  cmd.run:
    - name: 'nova flavor-delete "server"'
    - onlyif: nova flavor-list | grep -w "server"
    - onchanges:
      - glance: UbuntuServertrusty

UbuntuServertrusty flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'server'
    - ram: 512
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: UbuntuServertrusty
    - require:
      - cmd: UbuntuServertrusty flavor delete

{% else %}

UbuntuServertrusty gone:
  glance.image_absent:
  - profile: virl
  - name: 'server'

UbuntuServertrusty flavor absent:
  cmd.run:
    - name: 'nova flavor-delete "server"'
    - onlyif: nova flavor-list | grep -w "server"
{% endif %}
