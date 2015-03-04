{% set ntp_server = salt['pillar.get']('virl:ntp_server', salt['grains.get']('ntp_server', 'pool.ntp.org')) %}

ntp:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - restart: True

ntpdate:
  pkg:
    - installed

/etc/ntp.conf:
  file.replace:
    - pattern: ^server.*
    - repl: server {{ ntp_server }} iburst
    - onlyif: ls /usr/sbin/ntpd

ntp stop:
    cmd.run:
      - name: service ntp stop

ntpdate sync:
    cmd.run:
      - name: ntpdate {{ ntp_server }}

ntp start:
    cmd.run:
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
