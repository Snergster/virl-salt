{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/')) %}

boto backup:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - upgrade: True
    - name: boto >= 2.35.0
