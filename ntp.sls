{% set ADMIN_PASS = salt['grains.get']('password', 'password') %}
{% set controllername = salt['grains.get']('hostname', 'localhost') %}
{% set ntp_server = salt['grains.get']('ntp_server', 'ntp.ubuntu.com') %}

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

# ntp.conf:
#   file:
#     - order: 3
#     - managed
#     - name: /etc/ntp.conf
#     - source: salt://virl/files/vntp.conf
#     - mode: 755
#     - require:
#       - pkg: ntp

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
