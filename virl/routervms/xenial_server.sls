{% set server = salt['pillar.get']('routervms:UbuntuServertrusty', True) %}
{% set serverpref = salt['pillar.get']('virl:server', salt['grains.get']('server', True)) %}

include:
  - virl.routervms.virl-core-sync

{% if server and serverpref %}

UbuntuServertrusty:
  glance.image_present:
  - profile: virl
  - name: 'server'
  - container_format: bare
  - min_disk: 3
  - min_ram: 0
  - is_public: True
  - checksum: 36ffdc30fe71020dcf319833d9578757
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/ubuntu-16.04-server-cloudimg-amd64-disk1.qcow2
  - property-hw_disk_bus: virtio
  - property-release: 16.04.1
  - property-serial: 1
  - property-subtype: server

UbuntuServertrusty flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "server"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "server"
    - onchanges:
      - glance: UbuntuServertrusty

UbuntuServertrusty flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'server'
    - ram: 512
    - disk: 0
    - vcpus: 1
  {% if virl.mitaka %}
    - profile: virl
  {% endif %}
    - onchanges:
      - glance: UbuntuServertrusty
    - require:
      - cmd: UbuntuServertrusty flavor delete

UbuntuServertrusty flavor create2:
  module.run:
    - name: nova.flavor_create
    - m_name: 'server'
    - profile: virl
    - ram: 512
    - disk: 0
    - vcpus: 1
    - onfail:
      - module: 'UbuntuServertrusty flavor create'

{% else %}

UbuntuServertrusty gone:
  glance.image_absent:
  - profile: virl
  - name: 'server'

UbuntuServertrusty flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "server"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "server"
{% endif %}
