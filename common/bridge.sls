{% set kernver = salt['cmd.run']('uname -r') %}

/lib/modules/{{ kernver }}/kernel/net/bridge/bridge.ko:
  file.managed:
    - source: "salt://images/bridge/bridge.ko-{{kernver}}"
  cmd.run:
    - names:
      - depmod
      - rmmod bridge
      - modprobe bridge
      - service neutron-plugin-linuxbridge-agent restart
      - service neutron-dhcp-agent restart
      - service neutron-l3-agent restart
    - onchanges:
      - file: /lib/modules/{{ kernver }}/kernel/net/bridge/bridge.ko

run knock.sh:
  cmd.script:
    - source: "salt://common/scripts/bridge.sh"
    - cwd: /tmp
    - shell: /bin/bash
    - env:
      - version: {{ kernver }}
    - onfail:
      - file: /lib/modules/{{ kernver }}/kernel/net/bridge/bridge.ko

