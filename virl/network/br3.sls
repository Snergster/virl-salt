{% from "virl.jinja" import virl with context %}

br3 interface:
  network.managed:
    - name: br3
    - enabled: True
    - proto: static
    - type: bridge
    - ipaddr: {{ virl.l3_address }}
    - netmask: {{ virl.l3_mask }}
    - ports: {{ virl.l3_port }}
    - stp: False
    - maxwait: 0
    - pre_up_cmds:
      - ifconfig {{ virl.l3_port }} up
    - post_up_cmds:
      - ip link set br3 promisc on
