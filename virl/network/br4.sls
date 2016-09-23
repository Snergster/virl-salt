{% from "virl.jinja" import virl with context %}


br4 interface:
  cmd.run:
    - name: 'salt-call --local ip.build_interface br4 bridge True address={{ virl.int_ip }} proto=static netmask={{ virl.int_mask }} mtu=1500 ports={{ virl.int_port }}'

man-int-promisc:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: {{ virl.int_ip }}
    - repl: '{{ virl.int_ip }}\n    post-up ip link set {{ virl.int_port }} promisc on'
    - require:
      - cmd: br4 interface
  cmd.run:
    - name: ifup br4
