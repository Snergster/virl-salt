{% from "virl.jinja" import virl with context %}

br1 interface:
  network.managed:
    - name: br1
    - enabled: True
    - proto: static
    - type: bridge
    - ipaddr: {{ virl.l2_address }}
    - netmask: {{ virl.l2_mask }}
    - ports: {{ virl.l2_port }}
    - stp: False
    - maxwait: 0
    - post_up_cmds:
      - ip link set br1 promisc on



