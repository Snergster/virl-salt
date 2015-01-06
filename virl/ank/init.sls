{% set ank = salt['pillar.get']('virl:ank', salt['grains.get']('ank', '19401')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/')) %}
{% set virltype = salt['grains.get']('virl_type', 'stable') %}
{% set cml = salt['grains.get']('cml', False ) %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set ank_ver_fixed = salt['pillar.get']('virl:ank_ver_fixed', salt['grains.get']('ank_ver_fixed', False)) %}
{% set ank_ver = salt['pillar.get']('virl:ank_ver', salt['grains.get']('ank_ver', '0.10.8')) %}


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
    - onlyif: 'test ! -e /etc/init.d/ank-webserver'

/etc/init.d/ank-webserver:
  file.replace:
    - pattern: '.*--port.*"'
    - repl: 'RUNNING_CMD="/usr/local/bin/ank_webserver --multi_user --port {{ ank }}"'
    - unless: grep {{ ank }} /etc/init.d/ank-webserver
    - require:
      - file: ank_init

/root/.autonetkit/autonetkit.cfg:
  file.managed:
    - makedirs: True
    - mode: 0755
    - onlyif: 'test ! -e /root/.autonetkit/autonetkit.cfg'
    - contents:  |
        [Http Post]
        port={{ ank }}
  cmd.run:
    - name: 'crudini --set /root/.autonetkit/autonetkit.cfg "Http Post" port {{ ank }}'
    - unless: grep {{ ank }} /root/.autonetkit/autonetkit.cfg


/etc/rc2.d/S98ank-webserver:
  file.symlink:
    - target: /etc/init.d/ank-webserver
    - onlyif: 'test ! -e /etc/rc2.d/S98ank-webserver'
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
      - tornado == 3.2.2

autonetkit check:
  pip.installed:
    - order: 2
    {% if ank_ver_fixed == false %}
    - name: autonetkit
    - upgrade: True
    {% else %}
    - name: autonetkit == {{ ank_ver }}
    {% endif %}
    - no_deps: True
    - use_wheel: True
    - no_index: True
    - find_links: "file:///var/cache/virl/ank"
    - require:
      - pip: ank_prereq
  cmd.wait:
    - names:
      - wheel install-scripts autonetkit
      - service ank-webserver start
    - onchanges:
      - pip: autonetkit check


{% if venv == 'qa' or venv == 'dev' %}

autonetkit_cisco alt:
  pip.installed:
    - name: autonetkit_cisco
    - order: 3
    - upgrade: True
    - use_wheel: True
    - no_deps: True
    - pre_releases: True
    - no_index: True
    - find_links: "file:///var/cache/virl/ank"
    - require:
      - pip: autonetkit check

autonetkit_cisco.so remove:
  file.absent:
    - name: /usr/local/lib/python2.7/dist-packages/autonetkit_cisco.so

{% else %}

autonetkit_cisco pip remove:
  pip.removed:
    - name: autonetkit_cisco


autonetkit_cisco:
  file.managed:
    - order: 3
    - source: salt://ank/{{ venv }}/autonetkit_cisco.so
    - name: /usr/local/lib/python2.7/dist-packages/autonetkit_cisco.so
    - require:
      - pip: autonetkit check
      - pip: autonetkit_cisco pip remove

{% endif %}

autonetkit_cisco_webui:
  pip.installed:
    - order: 4
    - upgrade: True
    - no_deps: True
    - use_wheel: True
    - no_index: True
    - name: autonetkit_cisco_webui
    - find_links: "file:///var/cache/virl/ank"
    - require:
      - pip: autonetkit check


ank-webserver:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: autonetkit check
