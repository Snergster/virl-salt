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

man-flat-promisc:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: {{ virl.l2_address }}
    - repl: '{{ virl.l2_address }}\n    post-up ip link set br1 promisc on'
    - require:
      - network: br1 interface

