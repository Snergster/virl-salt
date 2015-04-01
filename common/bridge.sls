{% set kernver = salt['cmd.run']('uname -r') %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

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

lacp_linuxbridge_neutron_agent:
      {% if masterless %}
  file.copy:
    - source: /srv/salt/openstack/neutron/files/lacp_linuxbridge_neutron_agent.py
    - force: true
    {% else %}
  file.managed:
    - source: "salt://openstack/neutron/files/lacp_linuxbridge_neutron_agent.py"
    {% endif %}
    - name: /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py


