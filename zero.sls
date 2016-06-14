{% set ifproxy = salt['grains.get']('proxy', 'False') %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set proxy = salt['grains.get']('http_proxy', 'None') %}

include:
  - openstack.repo
  - common.pip

virl-group:
  group.present:
    - name: virl

libvirt-group:
  group.present:
    - name: libvirtd

virl-user:
  user.present:
    - name: virl
    - fullname: virl
    - name: virl
    - shell: /bin/bash
    - home: /home/virl
    - password: $6$SALTsalt$789PO2/UvvqTk1tGEj67KEOSPbQqqd9wEEBPqTrAuqNO1rTeNruN.IiVxXZX6w8kfEnt7q5eyz/aOFwlZow/b0

/etc/sudoers.d/virl:
  file.managed:
    - mode: 0440
    - create: True
    - contents: |
         virl ALL=(root) NOPASSWD:ALL
         Defaults:virl secure_path=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt:/opt/bin:/opt/support
         Defaults env_keep += "http_proxy https_proxy HTTP_PROXY HTTPS_PROXY OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_AUTH_URL"
  
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
    {% if ifproxy == True %}
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
