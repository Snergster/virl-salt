{% set iosxrv52 = salt['pillar.get']('routervms:iosxrv52', False ) %}
{% set iosxrv52pref = salt['pillar.get']('virl:iosxrv52', salt['grains.get']('iosxrv52', False)) %}

{% if iosxrv52 and iosxrv52pref %}
iosxrv52:
  glance.image_present:
  - profile: virl
  - name: 'IOS XRv52'
  - container_format: bare
  - min_disk: 0
  - min_ram: 0
  - is_public: True
  - checksum: dbbd206a25ac19ba5b4a1b1f65aed911
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/iosxrv-k9-demo-5.2.2.qcow2
  - property-config_disk_type: cdrom
  - property-hw_cdrom_type: id
  - property-hw_disk_bus: ide
  - property-hw_vif_model: virtio
  - property-release: 5.2.2
  - property-serial: 3
  - property-subtype: 'IOS XRv'


iosxrv52 flavor delete:
  cmd.run:
    - name: 'nova flavor-delete "IOS XRv52"'
    - onlyif: nova flavor-list | grep -w "IOS XRv52"
    - onchanges:
      - glance: iosxrv52

iosxrv52 flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOS XRv52'
    - ram: 3096
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: iosxrv52
    - require:
      - cmd: iosxrv52 flavor delete

{% else %}

iosxrv52 gone:
  glance.image_absent:
  - profile: virl
  - name: 'IOS XRv52'

iosxrv52 flavor absent:
  cmd.run:
    - name: 'nova flavor-delete "IOS XRv52"'
    - onlyif: nova flavor-list | grep -w "IOS XRv52"
{% endif %}
