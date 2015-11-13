{% set securityonion = salt['pillar.get']('routervms:securityonion', False) %}
{% set securityonionpref = salt['pillar.get']('virl:securityonion', salt['grains.get']('securityonion', True)) %}

{% if securityonion and securityonionpref %}
security-onion:
  glance.image_present:
    - profile: virl
    - name: 'security-onion'
    - container_format: bare
    - min_disk: 6
    - min_ram: 1024
    - is_public: True
    - checksum: c9f8acedc7510280cc3e27896b411196
    - protected: False
    - disk_format: qcow2
    - copy_from: salt://images/salt/securityonion-12.04.5.3.qcow2
    - property-hw_disk_bus: virtio
    - property-hw_disk_bus: ide
    - property-release: 12.04.5.3
    - property-serial: 1
    - property-subtype: security-onion

security-onion flavor delete:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "security-onion"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-show "security-onion"
    - onchanges:
      - glance: security-onion

security-onion flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'security-onion'
    - ram: 3096
    - disk: 8
    - vcpus: 1
    - onchanges:
      - glance: security-onion
    - require:
      - cmd: security-onion flavor delete

{% else %}

security-onion gone:
  glance.image_absent:
  - profile: virl
  - name: 'security-onion'

security-onion flavor absent:
  cmd.run:
    - name: 'source /usr/local/bin/virl-openrc.sh ;nova flavor-delete "security-onion"'
    - onlyif: source /usr/local/bin/virl-openrc.sh ;nova flavor-list | grep -w "security-onion"
{% endif %}
