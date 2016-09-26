{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', true)) %}
{% set kernvers = salt['grains.get']('kernels_to_bridge_patch', [salt['cmd.run']('uname -r')]) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}
{% set cluster = salt['pillar.get']('virl:virl_cluster', salt['grains.get']('virl_cluster', False )) %}

{% if packet %}
update sourcelist to include sources:
  file.append:
    - name: /etc/apt/sources.list
    - text:
      - 'deb-src [arch=amd64] http://us.archive.ubuntu.com/ubuntu trusty main universe'
      - 'deb-src [arch=amd64] http://us.archive.ubuntu.com/ubuntu trusty-updates main universe'
      - 'deb-src [arch=amd64] http://us.archive.ubuntu.com/ubuntu trusty-security main universe'
  cmd.run:
    - name: 'apt-get update -qq'
    - onchanges:
      - file: update sourcelist to include sources
{% endif %}

{% if 'xenial' in salt['grains.get']('oscodename') %}

update sourcelist to include xenial sources:
  file.append:
    - name: /etc/apt/sources.list
    - text:
      - 'deb-src [arch=amd64] http://us.archive.ubuntu.com/ubuntu xenial main universe'
      - 'deb-src [arch=amd64] http://us.archive.ubuntu.com/ubuntu xenial-updates main universe'
      - 'deb-src [arch=amd64] http://us.archive.ubuntu.com/ubuntu xenial-security main universe'
  cmd.run:
    - name: 'apt-get update -qq'
    - onchanges:
      - file: update sourcelist to include sources

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
{% if packet %}
    - require:
      - cmd: update sourcelist to include sources
{% endif %}
  {% if not 'xenial' in salt['grains.get']('oscodename') %}

run bridge.sh {{ kernver }}:
  cmd.script:
    - source: "salt://common/scripts/bridge.sh"
    - template: jinja
    - cwd: /tmp
    - shell: /bin/bash
    - env:
      - version: {{ kernver }}

  {% endif %}

{% endfor %}

