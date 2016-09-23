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

man-snat-promisc:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: {{ virl.l3_address }}
    - repl: '{{ virl.l3_address }}\n    post-up ip link set {{virl.l3_port}} promisc on'
    - require:
      - network: br3 interface
