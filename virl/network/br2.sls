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


man-flat2-address:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: {{ virl.l2_address2 }}
    - repl: '{{ virl.l2_address2 }}\n    post-up ip link set br2 promisc on'
    - require:
      - network: br2 interface
