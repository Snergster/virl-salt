{% from "virl.jinja" import virl with context %}

{% if virl.cml %}

/etc/set-motd:
  file.managed:
    - source: "salt://files/motd-cml"
    - user: virl
    - group: virl
    - file_mode: 755

{% else %}

/etc/set-motd:
  file.managed:
    - source: "salt://files/motd-virl"
    - user: virl
    - group: virl
    - file_mode: 755

{% endif %}

set-motd:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 007s motd"
    - marker_end: "# 007e end"
    - content: |
             /etc/set-motd
