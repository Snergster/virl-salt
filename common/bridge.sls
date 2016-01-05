{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}
{% set kernvers = salt['grains.get']('kernels_to_bridge_patch', [salt['cmd.run']('uname -r')]) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

{% for kernver in kernvers %}

/lib/modules/{{ kernver }}/kernel/net/bridge/bridge.ko:
  file.managed:
    - source: "salt://images/bridge/bridge.ko-{{kernver}}"

run bridgebuilder.sh {{ kernver }}:
  cmd.script:
    - source: "salt://common/scripts/bridgebuilder.sh"
    - cwd: /tmp
    - shell: /bin/bash
    - env:
      - version: {{ kernver }}
    - onfail:
      - file: /lib/modules/{{ kernver }}/kernel/net/bridge/bridge.ko

run bridge.sh {{ kernver }}:
  cmd.script:
    - source: "salt://common/scripts/bridge.sh"
    - template: jinja
    - cwd: /tmp
    - shell: /bin/bash
    - env:
      - version: {{ kernver }}

{% endfor %}

{% if not kilo %}
lacp_linuxbridge_neutron_agent:
  file.managed:
    - source: "salt://openstack/neutron/files/linuxbridge_neutron_agent.py"
    - name: /usr/lib/python2.7/dist-packages/neutron/plugins/linuxbridge/agent/linuxbridge_neutron_agent.py
  cmd.wait:
    - watch:
      - file: lacp_linuxbridge_neutron_agent
    - name:  |
         service neutron-server restart
         service neutron-plugin-linuxbridge-agent restart
{% endif %}




