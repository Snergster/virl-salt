{% from "virl.jinja" import virl with context %}

include:
{% if virl.packet %}
  - virl.ini-writeout
  - common.virluser
{% endif %}
  - virl.vsalt
  - virl.vextra
{% if virl.packet %}
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
