{% from "virl.jinja" import virl with context %}

{% if virl.kali and virl.kalipref %}

kali:
  glance.image_present:
  - profile: virl
  - name: 'kali'
  - container_format: bare
  - min_disk: 3
  - min_ram: 0
  - is_public: True
  - checksum: e52cfb43cff5e7b198d4d8e2412f5e68
  - protected: False
  - disk_format: qcow2
  - copy_from: salt://images/salt/kali_light-2.0.qcow2
  - property-hw_disk_bus: virtio
  - property-release: 2.0
  - property-serial: 1
  - property-subtype: kali

kali flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "kali"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "kali"
    - onchanges:
      - glance: kali

kali flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'kali'
    - ram: 2048
    - disk: 0
    - vcpus: 1
  {% if virl.mitaka %}
    - profile: virl
  {% endif %}
    - onchanges:
      - glance: kali
    - require:
      - cmd: kali flavor delete

{% else %}

kali gone:
  glance.image_absent:
  - profile: virl
  - name: 'kali'

kali flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "kali"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "kali"
{% endif %}
