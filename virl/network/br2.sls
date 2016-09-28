{% from "virl.jinja" import virl with context %}

br2 interface:
  network.managed:
    - name: br2
    - enabled: True
    - proto: static
    - type: bridge
    - ipaddr: {{ virl.l2_address2 }}
    - netmask: {{ virl.l2_mask2 }}
    - ports: {{ virl.l2_port2 }}
    - stp: False
    - maxwait: 0
    - pre_up_cmds:
      - ifconfig {{ virl.l2_port2 }} up
    - post_up_cmds:
      - ip link set br2 promisc on
