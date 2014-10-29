{% set ank = salt['pillar.get']('virl:ank', salt['grains.get']('ank', '19401')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/')) %}
{% set virltype = salt['grains.get']('virl_type', 'stable') %}
{% set cml = salt['grains.get']('cml', False ) %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}

/var/cache/virl/ank:
  file.recurse:
    - order: 1
    - user: virl
    - group: virl
    - file_mode: 755
    - source: "salt://ank/{{ venv }}/"

ank_init:
  file.managed:
    - order: 2
    - name: /etc/init.d/ank-webserver
    - source: "salt://files/ank-webserver.init"
    - mode: 0755

/root/.autonetkit/autonetkit.cfg:
  file.managed:
    - order: 3
    - makedirs: True
    - source: "salt://files/autonetkit.cfg"
    - mode: 0755

/etc/rc2.d/S98ank-webserver:
  file.symlink:
    - target: /etc/init.d/ank-webserver
    - mode: 0755

ank_prereq:
  pip.installed:
    {% if proxy == true %}
    - proxy: {{ http_proxy }}
    {% endif %}
    - names:
      - lxml
      - configobj
      - six
      - Mako
      - MarkupSafe
      - certifi
      - backports.ssl_match_hostname
      - netaddr
      - networkx
      - PyYAML
      - tornado == 3.0.1

autonetkit:
  pip.installed:
    - order: 2
    - upgrade: True
    - use_wheel: True
    - no_index: True
    - find_links: "file:///var/cache/virl/ank"
    - require:
      - pip: ank_prereq
  cmd.wait:
    - names:
      - wheel install-scripts autonetkit
      - service ank-webserver start
    - watch:
      - pip: autonetkit


{% if venv == 'qa' or venv == 'dev' %}

autonetkit_cisco alt:
  pip.installed:
    - name: autonetkit_cisco
    - order: 3
    - upgrade: True
    - use_wheel: True
    - pre_releases: True
    - no_index: True
    - find_links: "file:///var/cache/virl/ank"
    - require:
      - pip: autonetkit

autonetkit_cisco.so remove:
  file.absent:
    - name: /usr/local/lib/python2.7/dist-packages/autonetkit_cisco.so

{% else %}

autonetkit_cisco pip remove:
  pip.removed:
    - name: autonetkit_cisco
    - order: 3

autonetkit_cisco:
  file.managed:
    - order: 3
    - source: salt://ank/{{ venv }}/autonetkit_cisco.so
    - name: /usr/local/lib/python2.7/dist-packages/autonetkit_cisco.so
    - require:
      - pip: autonetkit
      - pip: autonetkit_cisco pip remove

{% endif %}

autonetkit_cisco_webui:
  pip.installed:
    - order: 4
    - upgrade: True
    - use_wheel: True
    - no_index: True
    - name: autonetkit_cisco_webui
    - find_links: "file:///var/cache/virl/ank"


/etc/init.d/ank-webserver:
  file.replace:
    - pattern: portnumber
    - repl: {{ ank }}

rootank:
  file.replace:
    - name: /root/.autonetkit/autonetkit.cfg
    - pattern: portnumber
    - repl: {{ ank }}

ank-webserver:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pip: autonetkit
