{% set ntp_server = salt['pillar.get']('virl:ntp_server', salt['grains.get']('ntp_server', 'ntp.ubuntu.com')) %}

ntp:
  pkg:
    - installed
    - order: 1
  service:
    - running
    - enable: True
    - restart: True

ntpdate:
  pkg:
    - order: 2
    - installed

/etc/ntp.conf:
  file.replace:
    - order: 4
    - pattern: ^server.*
    - repl: server {{ ntp_server }}
    - require:
      - pkg: ntp

ntp stop:
    cmd.run:
      - order: 5
      - name: service ntp stop

ntpdate sync:
    cmd.run:
      - order: 6
      - name: ntpdate {{ ntp_server }}

ntp start:
    cmd.run:
      - order: 7
      - name: service ntp start

/etc/init/ntpd.conf:
  file.managed:
    - mode: 644
    - contents: |
       start on runlevel [2345]
       stop on runlevel [!2345]
       exec /etc/init.d/ntp start

old ntp remove:
  file.absent:
    - name: /etc/init/ntp.conf
