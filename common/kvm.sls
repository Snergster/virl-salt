{% from "virl.jinja" import virl with context %}

{% if virl.serial_timeout_disabled %}
{% set telnet_front_enabled = 0 %}
{% else %}
{% set telnet_front_enabled = 1 %}
{% endif %}

include:
  - common.numa

{% if virl.mitaka %}

# sysv script for systemd to use
/usr/share/qemu/init/qemu-kvm-init:
  file.managed:
    - makedirs: True
    - mode: 755
    - source: salt://common/files/qemu-kvm-init
    - unless: test -e /usr/share/qemu/init/qemu-kvm-init
/etc/init.d/qemu-kvm:
  file.managed:
    - mode: 755
    - source: salt://common/files/qemu-kvm
    - unless: test -e /etc/init.d/qemu-kvm
qemu-kvm systemd reload:
  cmd.run:
    - name: systemctl daemon-reload
{% endif %}

libvirt install:
  pkg.installed:
    - name: libvirt-bin
    - aggregate: False
    - skip_verify: True
    - refresh: True

{% if not '2.0.0' in salt['cmd.shell']('/usr/bin/qemu-system-x86_64 --version') %}

qemu unhold:
  module.run:
    - name: pkg.unhold
    - pkgs:
      - qemu-system-x86
      - qemu-kvm
      - qemu-system-common

qemu purge:
  pkg.purged:
    - require:
      - module: qemu unhold
    - pkgs:
      - qemu-system-x86
      - qemu-kvm
      - qemu-system-common


{% endif %}

qemu install:
  pkg.installed:
    - pkgs:
      - qemu-system-x86
      - qemu-kvm
      - qemu-system-common
    - refresh: True
{% if not virl.mitaka %}
    - hold: True
    - fromrepo: trusty
{% endif %}

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
kvm socket proxy:
  file.replace:
    - name: /usr/bin/kvm
    - pattern: '^TELNET_FRONT_ENABLED=.*'
    - repl: 'TELNET_FRONT_ENABLED={{ telnet_front_enabled }}'

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



