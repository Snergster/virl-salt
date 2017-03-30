{% from "virl.jinja" import virl with context %}

{% if virl.cml %}

set-motd-cml:
  file.managed:
    - name: /etc/set-motd
    - source: "salt://files/motd-cml"
    - user: root
    - group: root
    - file_mode: keep

{% else %}

set-motd-virl:
  file.managed:
    - name: /etc/set-motd
    - source: "salt://files/motd-virl"
    - user: root
    - group: root
    - file_mode: keep

{% endif %}

hammer-the-execute-bit:
  cmd.run:
    - name: chmod 0755 /etc/set-motd

call-motd-in-etc:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 007s motd"
    - marker_end: "# 007e end"
    - content: |
             /etc/set-motd
