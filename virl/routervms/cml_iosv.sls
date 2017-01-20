{% set cml_iosv = salt['pillar.get']('routervms:cml_iosv', False ) %}
{% set cml_iosvpref = salt['pillar.get']('virl:cml_iosv', salt['grains.get']('cml_iosv', True)) %}

{% if cml_iosv and cml_iosvpref %}

iosv:
  glance.image_present:
    - profile: virl
    - name: 'IOSv'
    - container_format: bare
    - min_disk: 2
    - min_ram: 0
    - is_public: True
    - checksum: d38cecec672522313c60d20edfea9773
    - protected: False
    - disk_format: qcow2
    - copy_from: salt://images/salt/vios-adventerprisek9-m.cml.vmdk.SPA.155-3.M
    - property-config_disk_type: disk
    - property-hw_cdrom_bus: ide
    - property-hw_disk_bus: virtio
    - property-hw_vif_model: e1000
    - property-release: 15.5.3.M
    - property-serial: 2
    - property-subtype: IOSv

iosv flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "IOSv"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "IOSv"
    - onchanges:
      - glance: iosv

iosv flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOSv'
    - ram: 512
    - disk: 0
    - vcpus: 1
  {% if virl.mitaka %}
    - profile: virl
  {% endif %}
    - onchanges:
      - glance: iosv
    - require:
      - cmd: iosv flavor delete

iosv flavor create2:
  module.run:
    - name: nova.flavor_create
    - m_name: 'IOSv'
    - profile: virl
    - ram: 512
    - disk: 0
    - vcpus: 1
    - onfail:
      - module: 'iosv flavor create'

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
