{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/')) %}
{% set l2_gateway = salt['pillar.get']('virl:l2_network_gateway', salt['grains.get']('l2_network_gateway', '172.16.1.254' )) %}
{% set l2_gateway2 = salt['pillar.get']('virl:l2_network_gateway2', salt['grains.get']('l2_network_gateway2', '172.16.2.254' )) %}
{% set l3_network_gateway = salt['pillar.get']('virl:l3_network_gateway', salt['grains.get']('l3_network_gateway', '172.16.3.254' )) %}

include:
  - virl.tinyproxy.install

/etc/tinyproxy.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://virl/tinyproxy/files/tinyproxy.conf"
    - require:
      - pkg: tinyproxy install

drop extra http from tinyproxy:
  file.replace:
    - name: /etc/tinyproxy.conf
    - pattern: upstream http://
    - repl: 'upstream '

drop extra https from tinyproxy:
  file.replace:
    - name: /etc/tinyproxy.conf
    - pattern: upstream https://
    - repl: 'upstream '

drop trailing slash from tinyproxy:
  file.replace:
    - name: /etc/tinyproxy.conf
    - pattern: /$
    - repl: ''

  service.running:
    - name: tinyproxy
    - onchanges:
      - file: drop extra http from tinyproxy
      - file: drop extra https from tinyproxy
      - file: drop trailing slash from tinyproxy


