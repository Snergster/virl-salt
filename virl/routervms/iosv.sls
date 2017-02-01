{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

{% if virl.iosvpref or virl.cml_iosv %}

iosv:
  glance.image_present:
    - profile: virl
    - name: 'IOSv'
    - container_format: bare
    - min_disk: 2
    - min_ram: 0
    - is_public: True
  {% if virl.cml %}
    - checksum: 4e94f3e63ad2771e5662f614921c8c62
    - copy_from: salt://images/salt/vios-adventerprisek9-m.cml.vmdk.SPA.156-2.T
  {% else %}
    - checksum: 83707e3cc93646da58ee6563a68002b5
    - copy_from: salt://images/salt/vios-adventerprisek9-m.vmdk.SPA.156-2.T
  {% endif %}
    - protected: False
    - disk_format: qcow2
    - property-config_disk_type: disk
    - property-hw_cdrom_bus: ide
    - property-hw_disk_bus: virtio
    - property-hw_vif_model: e1000
    - property-release: 15.6.2.T
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
  {% if virl.mitaka %}
    - profile: virl
  {% endif %}
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
