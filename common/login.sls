{% from "virl.jinja" import virl with context %}

{% if virl.cml %}

set-motd-cml:
  file.managed:
    - name: /etc/update-motd.d/60-cml
    - source: salt://files/60-cml
    - user: root
    - group: root
    - file_mode: keep

{% else %}

set-motd-virl:
  file.managed:
    - name: /etc/update-motd.d/60-virl
    - source: salt://files/60-virl
    - user: root
    - group: root
    - file_mode: keep

{% endif %}

set-motd-sysinfo:
  file.managed:
    - name: /etc/update-motd.d/50-landscape-sysinfo
    - source: salt://files/50-landscape-sysinfo
    - user: root
    - group: root
    - file_mode: keep

kill-10-help:
  file.absent:
    - name: /etc/update-motd.d/10-help-text

hammer-the-execute-bits:
  cmd.run:
    - name: chmod 0755 /etc/update-motd.d/*

mask-libvirt-in-lightdm:
  file.managed:
    - name: /var/lib/AccountsService/users/libvirt-qemu
    - source: salt://files/libvirt-qemu
    - user: root
    - group: root
    - file_mode: keep
