{% from "virl.jinja" import virl with context %}

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


/etc/ntp.conf jinja:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://virl/files/ntp.conf
    - template: jinja

{% if not virl.dhcp %}
ntp.conf interface lock:
  file.replace:
    - name: /etc/ntp.conf
    - pattern: ^#interface
    - repl: interface
    - onlyif: ls /etc/ntp.conf
{% endif %}


ntp stop:
    cmd.run:
      - name: service ntp stop

ntpdate sync:
    cmd.run:
{% if virl.controller %}
      - name: ntpdate {{ virl.ntp_server }}
{% else %}
      - name: ntpdate {{ virl.controller_ip }}
{% endif %}

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
