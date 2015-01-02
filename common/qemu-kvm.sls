qemu_kvm unhold:
  module.run:
    - name: pkg.unhold
    - m_name: qemu_kvm

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
    - source: "salt://files/install_scripts/kvm"
    - mode: 0755
    - require:
      - pkg: manual qemu-kvm

qemu hold:
  apt.held:
    - name: qemu-kvm
    - require:
      - file: kvm virl version
