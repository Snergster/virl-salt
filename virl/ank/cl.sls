
/usr/local/bin/telnetproxy.linux:
  file.managed:
    - source: "salt://virl/ank/files/telnetproxy.linux"
    - mode: 0755


/usr/local/bin/telnetserver.linux:
  file.managed:
    - source: "salt://virl/ank/files/telnetserver.linux"
    - mode: 0755


/etc/init/telnetproxy.conf:
  file.managed:
    - source: "salt://virl/ank/files/telnetproxy.conf"
    - mode: 0755
    - require:
      - file: /usr/local/bin/telnetproxy.linux

telnetproxy:
  service.running:
    - name: telnetproxy
    - order: last
    - enable: True
    - restart: True
    - require:
      - file: /etc/init/telnetproxy.conf

mgmt_lxc_replace:
  file.managed:
    - name: /usr/local/lib/python2.7/dist-packages/virl_pkg_data/low_level/lxc/mgmt.lxc
    - source: "salt://virl/ank/files/mgmt.lxc"
    - mode: 0755
    - require:
      - file: /usr/local/bin/telnetproxy.linux

virl-std:
  service:
    - running
    - order: last
    - enable: True
    - restart: True
    - onlyif: ls /usr/local/bin/virl_std_server
    - watch:
      - file: mgmt_lxc_replace

virl-uwm:
  service:
    - running
    - order: last
    - enable: True
    - restart: True
    - onlyif: ls /usr/local/bin/virl_uwm_server
    - watch:
      - file: mgmt_lxc_replace

ank-cisco-webserver:
  service:
    - running
    - order: last
    - enable: True
    - restart: True
    - watch:
      - file: mgmt_lxc_replace
