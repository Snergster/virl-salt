/usr/local/bin/telnetproxy.linux:
  file.absent

/usr/local/bin/telnetserver.linux:
  file.absent

/etc/init/virl-webmux.conf:
  file.absent

virl-webmux:
  service.dead:
    - name: virl-webmux
    - order: last
    - enable: False

mgmt_lxc_replace:
  file.managed:
    - name: /usr/local/lib/python2.7/dist-packages/virl_pkg_data/low_level/lxc/mgmt.lxc
    - source: "salt://virl/ank/files/mgmt.lxc.orig"
    - mode: 0755

virl-std:
  service:
    - running
    - order: last
    - enable: True
    - restart: True
    - watch:
      - file: mgmt_lxc_replace

virl-uwm:
  service:
    - running
    - order: last
    - enable: True
    - restart: True
    - watch:
      - file: mgmt_lxc_replace
