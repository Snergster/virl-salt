{% set mitaka = salt['pillar.get']('virl:mitaka', salt['grains.get']('mitaka', false)) %}

include:
  - common.numa

libvirt install:
  pkg.installed:
    - name: libvirt-bin
    - aggregate: False
    - skip_verify: True
    - refresh: True

{% if mitaka %}
/etc/apt/sources.list.d/virl-qemu-trusty.list:
  file.managed:
    - mode: 0644
    - contents:  |
          deb http://us.archive.ubuntu.com/ubuntu/ trusty main restricted
          deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates main restricted
{% endif %}

qemu install:
  pkg.installed:
    - pkgs:
      - qemu-system-x86
      - qemu-kvm
      - qemu-system-common
    - refresh: True
# need to keep trusty version, xrv does not work with network
#{% if not mitaka %}
#{% endif %}
    - hold: True
    - fromrepo: trusty

libvirt-bin insert /dev/kvm:
  file.line:
    - name: /etc/init/libvirt-bin.conf
    - content: '[ -e /dev/kvm ] || touch /dev/kvm'
    - mode: Ensure
    - after: 'pre-start script'

/usr/bin/kvm:
  file.managed:
    - source: "salt://openstack/nova/files/kilo.kvm"
    - force: True
    - mode: 0755

/usr/bin/kvm.real:
  file.symlink:
    - target: /usr/bin/qemu-system-x86_64
    - mode: 0755
    - require:
      - file: /usr/bin/kvm

uncomment min vnc port:
  file.uncomment:
    - name: /etc/libvirt/qemu.conf
    - regex: remote_display_port_min.*
    - require:
      - pkg: libvirt install

alter min vnc port:
  file.replace:
    - name: /etc/libvirt/qemu.conf
    - pattern: remote_display_port_min = 59..
    - repl: remote_display_port_min = 5950
    - require:
      - file: uncomment min vnc port



