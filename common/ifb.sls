ifb modprobe:
  file.append:
    - name: /etc/modules
    - text: ifb numifbs=32
    - unless: grep ifb /etc/modules
  cmd.run:
    - name: modprobe ifb numifbs=32
    - unless: grep "^ifb" /proc/modules
