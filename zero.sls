{% set ifproxy = salt['grains.get']('proxy', false) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set proxy = salt['grains.get']('http_proxy', 'None') %}

include:
  - openstack.repo
  - common.pip
  - common.virluser

libvirt-group:
  group.present:
    - name: libvirtd

openssh-server:
  pkg.installed:
   - refresh: False

crudini:
  pkg.installed:
   - refresh: False

{% for pyreq in 'wheel','envoy','docopt','sh' %}
{{ pyreq }}:
  pip.installed:
    - require:
      - file: first-vinstall
    {% if ifproxy %}
    - proxy: {{ proxy }}
    {% endif %}
{% endfor %}

configparserus:
  pip.installed:
    {% if ifproxy %}
    - proxy: {{ proxy }}
    {% endif %}
    - name: configparser>=3.3.0r2

configparser fallback:
  pip.installed:
    {% if ifproxy %}
    - proxy: {{ proxy }}
    {% endif %}
    - name: configparser
    - onfail:
      - pip: configparserus

/usr/local/bin/openstack-config:
  file.symlink:
    - target: /usr/bin/crudini
    - mode: 0755
    - require:
      - pkg: crudini

first-vinstall:
  file.managed:
    - name: /usr/local/bin/vinstall
    - source: salt://virl/files/vinstall.py
    - user: virl
    - group: virl
    - mode: 0755
