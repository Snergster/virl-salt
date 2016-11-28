{% set iosxrvpref = salt['pillar.get']('virl:iosxrv', salt['grains.get']('iosxrv', True)) %}
{% set iosxrv = salt['pillar.get']('routervms:iosxrv', False ) %}

include:
  - virl.routervms.virl-core-sync

{% if iosxrv and iosxrvpref %}

iosxrv:
  glance.image_present:
  - profile: virl
  - name: 'IOS XRv'
  - container_format: bare
  - min_disk: 4
  - min_ram: 0
  - is_public: True
  - checksum: {{ salt['pillar.get']('routervm_checksums:iosxrv')}}
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/{{ salt['pillar.get']('routervm_files:iosxrv')}}
  - property-config_disk_type: cdrom
  - property-hw_cdrom_bus: ide
  - property-hw_disk_bus: ide
  - property-hw_vif_model: virtio
  - property-release: {{ salt['pillar.get']('version:iosxrv')}}
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

{% else %}

iosxrv gone:
  glance.image_absent:
  - profile: virl
  - name: 'IOS XRv'

iosxrv flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "IOS XRv"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "IOS XRv"
{% endif %}
