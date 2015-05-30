{% set iosv = salt['pillar.get']('routervms:iosv', False ) %}
{% set iosvpref = salt['pillar.get']('virl:iosv', salt['grains.get']('iosv', True)) %}
{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}
{% set cml_iosv = salt['pillar.get']('routervms:cml_iosv', False ) %}

{% if iosv or cml_iosv %}

iosv:
  glance.image_present:
    - profile: virl
    - name: 'IOSvo'
    - container_format: bare
    - min_disk: 2
    - min_ram: 0
    - is_public: True
    - checksum: 59c38ef98912f6e319142ee896b5b593
    - copy_from: salt://images/salt/vios-adventerprisek9-m-15.4.3M.qcow2
    - protected: False
    - disk_format: qcow2
    - property-config_disk_type: disk
    - property-hw_cdrom_type: ide
    - property-hw_disk_bus: virtio
    - property-hw_vif_model: e1000
    - property-release: 15.5.2.M
    - property-serial: 2
    - property-subtype: IOSv

iosv flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "IOSv"'
    - onlyif: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-show "IOSv"'
    - onchanges:
      - glance: iosv

iosv flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOSvo'
    - ram: 512
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: iosv
    - require:
      - cmd: iosv flavor delete

{% else %}

iosv gone:
  glance.image_absent:
  - profile: virl
  - name: 'IOSv'

iosv flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "IOSv"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "IOSv"
{% endif %}
