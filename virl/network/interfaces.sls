{% from "virl.jinja" import virl with context %}

include:
  - virl.network.system
  - virl.network.br4
  - virl.network.br1
  - virl.network.br3
  - virl.network.br2

br1 bringup:
  cmd.run:
    - unless: ifconfig br1
    - name: /sbin/ifup br1

br2 bringup:
  cmd.run:
    - unless: ifconfig br2
    - name: /sbin/ifup br2

br3 bringup:
  cmd.run:
    - unless: ifconfig br3
    - name: /sbin/ifup br3

br4 bringup:
  cmd.run:
    - unless: ifconfig br4
    - name: /sbin/ifup br4
