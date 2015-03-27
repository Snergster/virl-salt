{% set iosxrv432 = salt['pillar.get']('routervms:iosxrv432', False ) %}
{% set iosxrv432pref = salt['pillar.get']('virl:iosxrv432', salt['grains.get']('iosxrv432', True)) %}

% if iosxrv432 and iosxrv432pref %}
iosxrv432:
  glance.image_present:
    - profile: virl
    - name: 'IOS XRv432'
    - container_format: bare
    - min_disk: 0
    - min_ram: 0
    - is_public: True
    - checksum:
    - protected: False
    - disk_format: qcow2
    - copy_from: salt://images/salt/xrvr-fullk9-demo-4.3.2.qcow2
    - property-config_disk_type: cdrom
    - property-hw_cdrom_type: id
    - property-hw_disk_bus: ide
    - property-hw_vif_model: virtio
    - property-release: 4.3.2
    - property-serial: 3
    - property-subtype: 'IOS XRv'


iosxrv432 flavor delete:
  cmd.run:
    - name: 'nova flavor-delete "IOS XRv432"'
    - onlyif: nova flavor-show "IOS XRv432"
    - onchanges:
      - glance: iosxrv432

iosxrv432 flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOS XRv432'
    - ram: 3096
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: iosxrv432
    - require:
      - cmd: iosxrv432 flavor delete

{% else %}

iosxrv52 gone:
  glance.image_absent:
    - profile: virl
    - name: 'IOS XRv432'

iosxrv52 flavor absent:
  cmd.run:
    - name: 'nova flavor-delete "IOS XRv432"'
    - onlyif: nova flavor-list | grep -w "IOS XRv432"
{% endif %}
