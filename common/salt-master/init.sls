{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}

include:
  - common.salt-master.install
  - common.salt-master.gitpython
  - common.salt-master.python-consul
  - common.salt-master.psutil

pip backup only:
  pkg.installed:
    - name: python-pip
    - unless: ls /usr/bin/pip

M2Crypto backup:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - upgrade: True
    - name: M2Crypto
    - require:
      - pkg: pip backup only


msgpack-python backup:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - name: msgpack-python
    - upgrade: True
    - require:
      - pkg: pip backup only


