{% set ank = salt['pillar.get']('virl:ank', salt['grains.get']('ank', '19401')) %}
{% set ank_live = salt['pillar.get']('virl:ank_live', salt['grains.get']('ank_live', '19402')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/')) %}
{% set virltype = salt['grains.get']('virl_type', 'stable') %}
{% set cml = salt['grains.get']('cml', False ) %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set ank_ver_fixed = salt['pillar.get']('virl:ank_ver_fixed', salt['grains.get']('ank_ver_fixed', False)) %}
{% set ank_ver = salt['pillar.get']('virl:ank_ver', salt['grains.get']('ank_ver', '0.10.8')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

{% if not masterless %}

/var/cache/virl/ank:
  file.recurse:
    - order: 1
    - user: virl
    - group: virl
    - file_mode: 755
    - source: "salt://ank/{{ venv }}/"

{% endif %}

ank_init:
  {% if masterless %}
  file.copy:
    - force: true
    - source: /srv/salt/virl/ank/files/ank-webserver.init
  {% else %}
  file.managed:
    - source: "salt://virl/ank/files/ank-webserver.init"
  {% endif %}
    - order: 2
    - name: /etc/init.d/ank-webserver
    - mode: 0755
    - onlyif: 'test ! -e /etc/init.d/ank-webserver'


/etc/init.d/ank-cisco-webserver:
  {% if not masterless %}
  file.managed:
    - source: "salt://virl/ank/files/ank-cisco-webserver.init"
  {% else %}
  file.copy:
    - force: true
    - source: /srv/salt/virl/ank/files/ank-cisco-webserver.init
  {% endif %}
    - mode: 0755

/etc/init.d/virl-vis:
  {% if not masterless %}
  file.managed:
    - source: "salt://virl/ank/files/virl-vis.init"
  {% else %}
  file.copy:
    - force: true
    - source: /srv/salt/virl/ank/files/virl-vis.init
  {% endif %}
    - mode: 0755

/etc/init.d/live-vis-webserver:
  {% if not masterless %}
  file.managed:
    - source: "salt://virl/ank/files/live-vis-webserver.init"
  {% else %}
  file.copy:
    - force: true
    - source: /srv/salt/virl/ank/files/live-vis-webserver.init
  {% endif %}
    - mode: 0755

/etc/init.d/ank-webserver port change:
  file.replace:
    - pattern: '.*--port.*"'
    - repl: 'RUNNING_CMD="/usr/local/bin/ank_webserver --multi_user --port {{ ank }}"'
    - unless: grep {{ ank }} /etc/init.d/ank-webserver
    - require:
      - file: ank_init

/etc/init.d/ank-cisco-webserver port change:
  file.replace:
    - name: /etc/init.d/ank-cisco-webserver
    - pattern: '.*--port.*"'
    - repl: 'RUNNING_CMD="/usr/local/bin/ank_cisco_webserver --multi_user --port {{ ank }}"'
    - unless: grep {{ ank }} /etc/init.d/ank-cisco-webserver
    - require:
      - file: /etc/init.d/ank-cisco-webserver

live-vis port change:
  file.replace:
    - name: /etc/init.d/live-vis-webserver
    - pattern: '.*--port.*"'
    - repl: 'RUNNING_CMD="/usr/local/bin/live_vis_webserver --multi_user --port {{ ank_live }}"'
    - unless: grep {{ ank }} /etc/init.d/live-vis-webserver
    - require:
      - file: /etc/init.d/ank-cisco-webserver

/root/.autonetkit/autonetkit.cfg:
  file.managed:
    - makedirs: True
    - mode: 0755
    - unless: grep {{ ank }} /root/.autonetkit/autonetkit.cfg
    - contents:  |
        [Http Post]
        port={{ ank }}

/etc/rc2.d/S98ank-webserver:
  file.symlink:
    - target: /etc/init.d/ank-webserver
    - unless: ls /usr/local/bin/ank_cisco_webserver
    - mode: 0755

/etc/rc2.d/S98ank-cisco-webserver:
  file.symlink:
    - target: /etc/init.d/ank-cisco-webserver
    - onlyif: ls /usr/local/bin/ank_cisco_webserver
    - mode: 0755
    - require:
      - pip: autonetkit_cisco

/etc/rc2.d/S98ank-webserver missing:
  file.missing:
    - target: /etc/init.d/ank-webserver
    - onlyif: ls /usr/local/bin/ank_cisco_webserver
    - mode: 0755

/etc/rc2.d/S98virl-vis:
  file.symlink:
    - target: /etc/init.d/virl-vis
    - require:
      - file: /etc/init.d/virl-vis
    - mode: 0755

/etc/rc2.d/S98live-vis-webserver:
  file.symlink:
    - target: /etc/init.d/live-vis-webserver
    - require:
      - file: /etc/init.d/live-vis-webserver
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

{% if venv == 'qa' or venv == 'dev' %}

autonetkit_cisco_webui:
  pip.installed:
    - order: 4
    - upgrade: True
    - no_deps: True
    - use_wheel: True
    - no_index: True
    - name: autonetkit_cisco_webui
    - find_links: "file:///var/cache/virl/ank"
    - onlyif: ls /var/cache/virl/ank/autonetkit_cisco_webui*
    - require:
      - pip: autonetkit check
  cmd.wait:
    - names:
      - wheel install-scripts autonetkit-cisco
      - service ank-cisco-webserver start
      - rm -f /etc/init.d/ank-webserver
    - onchanges:
      - pip: autonetkit_cisco_webui

virl_collection:
  pip.installed:
    - order: 4
    - upgrade: True
    - no_deps: True
    - use_wheel: True
    - no_index: True
    - name: virl_collections
    - find_links: "file:///var/cache/virl/ank"
    - onlyif: ls /var/cache/virl/ank/virl_collection*
    - require:
      - pip: autonetkit check
  cmd.wait:
    - names:
      - wheel install-scripts virl-collection
      - service ank-cisco-webserver restart
      - rm -f /etc/init.d/ank-webserver
    - onchanges:
      - pip: virl_collections



ank-cisco-webserver:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: autonetkit_cisco_webui

live-vis-webserver:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: virl_collections

virl-vis:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: virl_collections

{% endif %}

ank-webserver:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: autonetkit check
