{% set ntp_server = salt['pillar.get']('virl:ntp_server', salt['grains.get']('ntp_server', 'pool.ntp.org')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set dhcp = salt['pillar.get']('virl:using_dhcp_on_the_public_port', salt['grains.get']('using_dhcp_on_the_public_port', True )) %}

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

{% if not dhcp %}
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
