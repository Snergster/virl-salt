{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}

{% if proxy %}
/etc/apt/apt.conf:
  file.managed:
    - contents:  |
          Acquire::http::proxy "{{http_proxy}}";
          Acquire::https::proxy "{{http_proxy}}";

proxy into pip.conf:
  file.touch:
    - name: /etc/pip.conf
    - onlyif: test ! -f /etc/pip.conf
  cmd.run:
    - name: crudini --set /etc/pip.conf global proxy {{http_proxy}}


{% else %}

/etc/apt/apt.conf remove :
  file.absent:
    - name: /etc/apt/apt.conf

proxy out of pip.conf:
  cmd.run:
    - name: crudini --del /etc/pip.conf global proxy 


{% endif %}