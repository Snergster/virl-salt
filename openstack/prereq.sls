{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set mitaka = salt['pillar.get']('virl:mitaka', salt['grains.get']('mitaka', false)) %}

openstack prereq lock:
  pip.installed:
  {% if proxy == true %}
    - proxy: {{ http_proxy }}
  {% endif %}
    - names:
{% if mitaka %}
      - oslo.messaging
      - oslo.middleware
      - python-novaclient
      - python-keystoneclient
      - oslo.config
      - oslo.rootwrap
      - pbr
      - oslo.i18n
      - oslo.serialization
      - oslo.utils
{% else %}
      - oslo.messaging == 1.6.0
      - oslo.middleware == 1.1.0
      - python-novaclient == 2.20.0
      - python-keystoneclient == 1.0.0
      - oslo.config == 1.6.0
      - oslo.rootwrap == 1.5.0
      - pbr == 0.10.8
      - oslo.i18n == 1.6.0
      - oslo.serialization == 1.5.0
      - oslo.utils == 1.5.0
{% endif %}
