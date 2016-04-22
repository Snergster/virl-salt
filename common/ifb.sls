ifb modprobe:
  file.append:
    - name: /etc/modules
    - text: ifb numifbs=32
    - unless: grep ifb /etc/modules
  cmd.run:
    - name: modprobe ifb numifbs=32
    - unless: grep "^ifb" /proc/modules

ifb_helper:
  file.managed:
    - name: /usr/local/bin/tc_ifb.sh
    - source: "salt://virl/std/files/tc_ifb.sh"
    - mode: 0755