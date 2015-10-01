{% set iosv = salt['pillar.get']('routervms:iosv', False ) %}
{% set iosvpref = salt['pillar.get']('virl:iosv', salt['grains.get']('iosv', True)) %}
{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}
{% set cml_iosv = salt['pillar.get']('routervms:cml_iosv', False ) %}

include:
  - virl.routervms.virl-core-sync

{% if iosv or cml_iosv %}

iosv:
  glance.image_present:
    - profile: virl
    - name: 'IOSv'
    - container_format: bare
    - min_disk: 2
    - min_ram: 0
    - is_public: True
  {% if cml %}
    - checksum: d38cecec672522313c60d20edfea9773
    - copy_from: salt://images/salt/vios-adventerprisek9-m.cml.vmdk.SPA.155-3.M
  {% else %}
    - checksum: 79f613ac3b179d5a64520730925130b2
    - copy_from: salt://images/salt/vios-adventerprisek9-m.vmdk.SPA.155-3.M
  {% endif %}
    - protected: False
    - disk_format: qcow2
    - property-config_disk_type: disk
    - property-hw_cdrom_type: ide
    - property-hw_disk_bus: virtio
    - property-hw_vif_model: e1000
    - property-release: 15.5.3.M
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
    - m_name: 'IOSv'
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
