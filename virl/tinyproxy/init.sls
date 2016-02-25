{% if salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
include:
  - virl.tinyproxy.install
  - virl.tinyproxy.configure
{% endif %}
