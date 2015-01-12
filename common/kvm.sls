{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}


/usr/bin/kvm:
  {% if masterless %}
  file.copy:
    - source: /srv/salt/openstack/nova/files/kvm
  {% else %}
  file.managed:
    - source: "salt://files/install_scripts/kvm"
  {% endif %}
    - force: True
    - order: 4
    - mode: 0755

/usr/bin/kvm.real:
  file.symlink:
    - order: 6
    - target: /usr/bin/qemu-system-x86_64
    - mode: 0755
    - require:
      - file: /usr/bin/kvm
