
{% from "virl.jinja" import virl with context %}


{% if not virl.masterless %}

/var/cache/virl/ank files:
  file.recurse:
    - name: /var/cache/virl/ank
    - source: "salt://ank/{{ virl.venv }}/"
    - user: virl
    - group: virl
    - file_mode: 755

{% endif %}


/etc/init.d/virl-vis-processor:
  file.managed:
    - source: "salt://virl/ank/files/virl-vis-processor.init"
    - mode: 0755

/etc/init.d/virl-vis-mux:
  file.managed:
    - source: "salt://virl/ank/files/virl-vis-mux.init"
    - mode: 0755


/etc/init.d/virl-vis-webserver:
  file.managed:
    - source: "salt://virl/ank/files/virl-vis-webserver.init"
    - mode: 0755

virl-vis-webserver port change:
  file.replace:
    - order: last
    - name: /etc/init.d/virl-vis-webserver
    - pattern: '.*--port.*"'
    - repl: 'RUN_CMD="/usr/local/bin/virl_live_vis_webserver --port {{ virl.ank_live }}"'
    - unless:
      - grep {{ virl.ank_live }} /etc/init.d/virl-vis-webserver
      - 'test ! -e  /etc/init.d/virl-vis-webserver'

/etc/rc2.d/S98virl-vis-processor:
  file.symlink:
    - target: /etc/init.d/virl-vis-processor
    - require:
      - file: /etc/init.d/virl-vis-processor
    - mode: 0755

/etc/rc2.d/S98virl-vis-mux:
  file.symlink:
    - target: /etc/init.d/virl-vis-mux
    - require:
      - file: /etc/init.d/virl-vis-mux
    - mode: 0755

/etc/rc2.d/S98virl-vis-webserver:
  file.symlink:
    - order: last
    - target: /etc/init.d/virl-vis-webserver
    - onlyif: 'test -e /etc/init.d/virl-vis-webserver'
    - mode: 0755


ank init script:
  file.managed:
    - name: /etc/init.d/ank-cisco-webserver
    - source: "salt://virl/ank/files/ank-cisco-webserver.init"
    - mode: 0755


ank symlink:
  file.symlink:
    - name: /etc/rc2.d/S98ank-cisco-webserver
    - target: /etc/init.d/ank-cisco-webserver
    - onlyif: ls /usr/local/bin/ank_cisco_webserver
    - mode: 0755
    - require:
      - pip: autonetkit_cisco

/root/.autonetkit/autonetkit.cfg:
  file.managed:
    - makedirs: True
    - mode: 0755
    - unless: grep {{ virl.ank }} /root/.autonetkit/autonetkit.cfg
    - contents:  |
        [Http Post]
        port={{ virl.ank }}

autonetkit check:
  pip.installed:
    - name: autonetkit
    - upgrade: True
    - find_links: "file:///var/cache/virl/ank"
    - no_deps: True
    - use_wheel: True
    - no_index: True
  cmd.wait:
    - names:
      - wheel install-scripts autonetkit
    - onchanges:
      - pip: autonetkit check

autonetkit_cisco:
  pip.installed:
    - name: autonetkit_cisco
    - upgrade: True
    - find_links: "file:///var/cache/virl/ank"
    - use_wheel: True
    - no_deps: True
    - pre_releases: True
    - no_index: True
    - require:
      - pip: autonetkit check

autonetkit_cisco_webui:
  pip.installed:
    - name: autonetkit_cisco_webui
    - find_links: "file:///var/cache/virl/ank"
    - onlyif: ls /var/cache/virl/ank/autonetkit_cisco_webui*
    - upgrade: True
    - no_deps: True
    - use_wheel: True
    - no_index: True
    - require:
      - pip: autonetkit check
      - pip: autonetkit_cisco
  cmd.wait:
    - names:
      - wheel install-scripts autonetkit-cisco
      - service ank-cisco-webserver start | at now + 1 min
    - onchanges:
      - pip: autonetkit_cisco_webui

virl_collection:
  pip.installed:
    - name: virl_collection
    - find_links: "file:///var/cache/virl/ank"
    - onlyif: ls /var/cache/virl/ank/virl_collection*
    - upgrade: True
    - no_deps: True
    - use_wheel: True
    - no_index: True
    - require:
      - pip: autonetkit check
  cmd.wait:
    - names:
      - wheel install-scripts virl-collection
      - service ank-cisco-webserver start | at now + 1 min
      - service virl-vis-webserver start | at now + 1 min
      - service virl-vis-processor start | at now + 1 min
      - service virl-vis-mux start | at now + 1 min
    - onchanges:
      - pip: virl_collection


/etc/init.d/virl-vis:
  file.absent

/etc/rc2.d/S98virl-vis:
  file.absent

/etc/rc2.d/S98ank-webserver:
  file.absent

ank-webserver:
  service.dead

/etc/init.d/ank-webserver:
  file.absent

/etc/rc2.d/S98live-vis-webserver:
  file.absent

/etc/init.d/live-vis-webserver:
  file.absent

autonetkit_cisco.so remove:
  file.absent:
    - name: /usr/local/lib/python2.7/dist-packages/autonetkit_cisco.so

substitute ank port:
  file.replace:
    - order: last
    - name: /etc/init.d/ank-cisco-webserver
    - pattern: '.*--port.*"'
    - repl: 'RUNNING_CMD="/usr/local/bin/ank_cisco_webserver --multi_user --port {{ virl.ank }}"'
    - unless:
      - grep {{ virl.ank }} /etc/init.d/ank-cisco-webserver
      - 'test ! -e /etc/init.d/ank-cisco-webserver'
  cmd.wait:
    - names:
      - service ank-cisco-webserver restart
    - onchanges:
      - file: substitute ank port


ank-cisco-webserver:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: autonetkit_cisco_webui

virl-vis-webserver:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - file: virl-vis-webserver port change
      - pip: virl_collection

virl-vis-processor:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: virl_collection

virl-vis-mux:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: virl_collection
