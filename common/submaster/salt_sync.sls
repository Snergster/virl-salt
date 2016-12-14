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

first attempt:
  git.latest:
    - name: https://github.com/Snergster/virl-salt.git
    - depth: 1
    - target: /srv/salt

just in case:
  git.latest:
    - target: /srv/salt
    - name: https://github.com/Snergster/virl-salt.git
    - depth: 1
    - force_clone: True
    - onfail:
      - git: first attempt

{% if virl.proxy %}
http_proxy unset:
  environ.setenv:
    - name: http_proxy
    - value: False
    - false_unsets: True

https_proxy unset:
  environ.setenv:
    - name: https_proxy
    - value: False
    - false_unsets: True

{% endif %}
