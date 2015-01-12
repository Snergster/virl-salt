{% set ifproxy = salt['grains.get']('proxy', 'False') %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

{% if masterless %}
/etc/apt/sources.list.d/cisco-openstack-mirror_icehouse.list:
  file.copy:
    - source: /srv/salt/virl/files/cisco-openstack-mirror_icehouse.list


/etc/apt/preferences.d/cisco-openstack:
  file.copy:
    - source: /srv/salt/virl/files/cisco-openstack-preferences
    - force: true


/tmp/cisco-openstack.key:
  cmd.run:
    - name: apt-key add /srv/salt/virl/files/cisco-openstack.key


{% else %}

/etc/apt/sources.list.d/cisco-openstack-mirror_icehouse.list:
  file.managed:
    - source: salt://virl/files/cisco-openstack-mirror_icehouse.list


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

{% endif %}

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

openssh-server:
  pkg.installed:
   - refresh: False

crudini:
  pkg.installed:
   - refresh: False

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

/usr/local/bin/openstack-config:
  file.symlink:
    - target: /usr/bin/crudini
    - mode: 0755
    - require:
      - pkg: crudini

first-vinstall:
{% if not masterless %}
  file.managed:
    - name: /usr/local/bin/vinstall
    - source: salt://virl/files/vinstall.py
    - user: virl
    - group: virl
    - mode: 0755
{% else %}
  file.symlink:
    - name: /usr/local/bin/vinstall
    - target: /srv/salt/virl/files/vinstall.py
    - mode: 0755
    - force: true
    - onlyif: 'test -e /srv/salt/virl/files/vinstall.py'
{% endif %}

  file.managed:
    - name: /usr/local/bin/vinstall
    - source: 'salt://files/vinstall.py'
    - mode: 0755
