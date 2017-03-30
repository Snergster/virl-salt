{% from "virl.jinja" import virl with context %}

{% if virl.cml %}

/etc/set-motd:
  file.managed:
    - source: "salt://files/motd-cml"
    - user: root
    - group: root
    - file_mode: '0755'

{% else %}

/etc/set-motd:
  file.managed:
    - source: "salt://files/motd-virl"
    - user: root
    - group: root
    - file_mode: '0755'

{% endif %}

set-motd:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 007s motd"
    - marker_end: "# 007e end"
    - content: |
             /etc/set-motd
