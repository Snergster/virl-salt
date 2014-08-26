{% set ank = salt['grains.get']('ank', '19401') %}
{% set virltype = salt['grains.get']('virl type', 'stable') %}
{% set proxy = salt['grains.get']('proxy', 'False') %}
{% set httpproxy = salt['grains.get']('http proxy', 'https://proxy-wsa.esl.cisco.com:80') %}

/tmp/ankfiles:
  file.recurse:
    - order: 1
    - user: virl
    - group: virl
    - file_mode: 755
    {% if grains['cml?'] == True %}
    - source: "salt://ank/release/cml/"
    {% elif virltype == 'stable' %}
    - source: "salt://ank/release/stable/"
    {% elif virltype == 'testing' %}
    - source: "salt://ank/release/testing/"
    {% endif %}

