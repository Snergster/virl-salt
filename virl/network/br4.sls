{% from "virl.jinja" import virl with context %}


br4 interface:
  network.managed:
    - name: br4
    - enabled: True
    - proto: static
    - type: bridge
    - ipaddr: {{ virl.int_ip }}
    - netmask: {{ virl.int_mask }}
    - ports: {{ virl.int_port }}
    - stp: False
    - maxwait: 0
    - pre_up_cmds:
      - ifconfig {{ virl.int_port }} up
    - post_up_cmds:
      - ip link set br4 promisc on
