{% from "virl.jinja" import virl with context %}

{% if virl.proxy %}

http_proxy std prereq:
  environ.setenv:
    - name: http_proxy
    - value: {{ virl.http_proxy }}

https_proxy std prereq:
  environ.setenv:
    - name: https_proxy
    - value: {{ virl.http_proxy }}

{% endif %}

prereqs:
  pip.installed
    - names:
      - netaddr

/usr/local/bin/virl_setup:
  file.managed
    - source: salt://virl/files/virl_setup.py
    - mode: 755
