{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}

include:
{% if packet %}
  - virl.ini-writeout
  - common.users
{% endif %}
  - virl.vsalt
  - virl.vextra
{% if packet %}
  - virl.packet_host
{% else %}
  - virl.host
  - virl.ntp
{% endif %}
  - virl.web


/var/www/download exists:
  file.directory:
    - name: /var/www/download
    - makedirs: True

/var/www/training exists:
  file.directory:
    - name: /var/www/training
    - makedirs: True

prefer ipv4:
  file.append:
    - name: /etc/gai.conf
    - text: 'precedence ::ffff:0:0/96  100'
