{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}



qemu_kvm unhold:
  module.run:
    - name: pkg.unhold
    - m_name: qemu-kvm
    - onlyif: ls /usr/bin/qemu-system-x86_64

/usr/bin/kvm:
  {% if masterless %}
  file.copy:
    - source: /srv/salt/openstack/nova/files/kvm
  {% else %}
  file.managed:
    - source: "salt://openstack/nova/files/kvm"
    {% endif %}
    - force: True
    - order: 4
    - mode: 0755

/usr/bin/kvm.real:
  file.symlink:
    - target: /usr/bin/qemu-system-x86_64
    - mode: 0755
    - require:
      - file: /usr/bin/kvm

manual qemu-kvm:
  pkg.uptodate:
    - name: qemu-kvm
    - refresh: True
    - require:
      - module: qemu_kvm unhold

kvm virl version:
  file.managed:
    - name: /usr/bin/kvm
    - onlyif: ls /usr/bin/kvm.real
    - source: "salt://openstack/nova/files/kvm"
    - mode: 0755
    - require:
      - pkg: manual qemu-kvm

qemu hold:
  apt.held:
    - name: qemu-kvm
    - require:
      - file: kvm virl version
