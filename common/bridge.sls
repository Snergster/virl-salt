{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}
{% set kernvers = salt['grains.get']('kernels_to_bridge_patch', [salt['cmd.run']('uname -r')]) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}

{% if packet %}
update sourcelist to include sources:
  file.append:
    - name: /etc/apt/sources.list
    - text:
      - 'deb-src [arch=amd64] http://us.archive.ubuntu.com/ubuntu trusty main universe'
      - 'deb-src [arch=amd64] http://us.archive.ubuntu.com/ubuntu trusty-updates main universe'
      - 'deb-src [arch=amd64] http://us.archive.ubuntu.com/ubuntu trusty-security main universe'
{% endif %}

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




