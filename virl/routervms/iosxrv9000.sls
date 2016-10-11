{% set iosxrv9000pref = salt['pillar.get']('virl:iosxrv9000', salt['grains.get']('iosxrv9000', True)) %}
{% set iosxrv9000 = salt['pillar.get']('routervms:iosxrv9000', False ) %}

include:
  - virl.routervms.virl-core-sync

{% if iosxrv9000 and iosxrv9000pref %}

iosxrv 9000:
  glance.image_present:
  - profile: virl
  - name: 'IOS XRv 9000'
  - container_format: bare
  - min_disk: 55
  - min_ram: 0
  - is_public: True
  - checksum: {{ salt['pillar.get']('routervm_checksums:iosxr9000')}}
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/{{ salt['pillar.get']('routervm_files:iosxr9000')}}
  - property-config_disk_type: cdrom
  - property-hw_cdrom_bus: ide
  - property-hw_disk_bus: virtio
  - property-hw_vif_model: virtio
  - property-release: {{ salt['pillar.get']('version:iosxr9000')}}
  - property-serial: 4
  - property-subtype: 'IOS XRv 9000'


iosxrv 9000 flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "IOS XRv 9000"'
    - onlyif: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-show "IOS XRv 9000"'
    - onchanges:
      - glance: iosxrv 9000

iosxrv 9000 flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOS XRv 9000'
    - ram: 16384
    - disk: 0
    - vcpus: 4
    - onchanges:
      - glance: iosxrv 9000
    - require:
      - cmd: iosxrv 9000 flavor delete

{% else %}

iosxrv 9000 gone:
  glance.image_absent:
  - profile: virl
  - name: 'IOS XRv 9000'

iosxrv 9000 flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "IOS XRv 9000"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "IOS XRv 9000"
{% endif %}
