{% set ifproxy = salt['grains.get']('http proxy', 'None') %}

/etc/apt/sources.list.d/cisco-openstack-mirror_icehouse.list:
  file.managed:
    - source: salt://virl/files/cisco-openstack-mirror_icehouse.list

/etc/apt/sources.list.d/docker.list:
  file.managed:
    - source: salt://virl/files/docker.list
  cmd.wait:
    - name: apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
    - cwd: /tmp
    - watch:
      - file: /etc/apt/sources.list.d/docker.list

/etc/apt/preferences.d/cisco-openstack:
  file.managed:
    - source: salt://virl/files/cisco-openstack-preferences

/tmp/cisco-openstack.key:
  file.managed:
    - source: salt://virl/files/cisco-openstack.key
  cmd.wait:
    - name: apt-key add /tmp/cisco-openstack.key
    - cwd: /tmp
    - watch:
      - file: /tmp/cisco-openstack.key

virl-group:
  group.present:
    - name: virl

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
    - order: 3
    - mode: 0440
    - create: True

sudoer-defaults:
    file.append:
        - order: 4
        - name: /etc/sudoers.d/virl
        - require:
          - user: virl-user
        - text:
          - virl ALL=(root) NOPASSWD:ALL
          - Defaults:virl secure_path=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt:/opt/bin:/opt/support
          - Defaults env_keep += "http_proxy https_proxy HTTP_PROXY HTTPS_PROXY OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_AUTH_URL"

python-pip:
  pkg.installed:
   - refresh: True

first-vinstall:
  file.managed:
    - name: /usr/local/bin/vinstall
    - source: 'salt://files/vinstall.py'
  cmd.wait:
    - name: /usr/local/bin/vinstall salt
    - name: rm -rf /tmp/install.out
    - name: rm -rf /tmp/grains
    - name: rm -rf /tmp/openstack
    - name: rm -rf /tmp/extra
    - watch:
      - file: /usr/local/bin/vinstall

{% for pyreq in 'wheel','envoy','docopt','sh','configparser>=3.3.0r2' %}
{{ pyreq }}:
  pip.installed:
    - require:
      - pkg: python-pip
      - file: first-vinstall
    {% if ifproxy == True %}
    {% set proxy = salt['grains.get']('http proxy', 'None') %}
    - proxy: {{ proxy }}
    {% endif %}
{% endfor %}
