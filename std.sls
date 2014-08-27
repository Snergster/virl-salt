{% set proxy = salt['grains.get']('proxy', 'False') %}
{% set password = salt['grains.get']('password', 'password') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'password') %}
{% set stdport = salt['grains.get']('virl webservices', '19399') %}
{% set uwmport = salt['grains.get']('virl user management', '19400') %}
{% set uwmpass = salt['grains.get']('uwmadmin password', 'password') %}
{% set httpproxy = salt['grains.get']('http proxy', 'https://proxy-wsa.esl.cisco.com:80/') %}

/tmp/stdfiles:
  file.recurse:
    - order: 1
    - user: virl
    - group: virl
    - file_mode: 755
    {% if grains['virl type'] == 'stable' and grains['cml?'] == False %}
    - source: "salt://std/release/stable/"
    {% elif grains['virl type'] == 'stable' and grains['cml?'] == True %}
    - source: "salt://std/cml/stable/"
    {% elif grains['virl type'] == 'testing' and grains['cml?'] == False %}
    - source: "salt://std/release/testing/"
    {% elif grains['virl type'] == 'testing' and grains['cml?'] == True %}
    - source: "salt://std/cml/testing/"
    {% endif %}

std_init:
  file.managed:
    - order: 3
    - name: /etc/init.d/virl-std
    - source: "salt://files/virl-std.init"
    - mode: 0755

/etc/virl/virl.cfg:
  file.managed:
    - order: 3
    - makedirs: true
    - mode: 0644

uwm_init:
  file.managed:
    - order: 4
    - name: /etc/init.d/virl-uwm
    - source: "salt://files/virl-uwm.init"
    - mode: 0755

/etc/rc2.d/S98virl-std:
  file.symlink:
    - order: 6
    - target: /etc/init.d/virl-std
    - mode: 0755

/etc/rc2.d/S98virl-uwm:
  file.symlink:
    - target: /etc/init.d/virl-uwm
    - mode: 0755


std_prereq:
  pip.installed:
    - order: 2
{% if grains['proxy'] == true %}
    - proxy: {{ httpproxy }}
{% endif %}
    - names:
      - ipaddr == 2.1.0
      - flask-sqlalchemy == 0.16
      - Flask == 0.9
      - Flask_Login == 0.2.7
      - Flask_RESTful == 0.1.2
      - Flask_WTF == 0.9.3
      - itsdangerous == 0.23
      - Jinja2 == 2.2.6
      - lxml == 3.1.0
      - MarkupSafe == 0.18
      - mock == 1.0.1
      - requests == 2.0.1
      - paramiko == 1.11.0
      - pycrypto == 2.6.1
      - simplejson == 2.1.6
      - sqlalchemy == 0.7.9
      - tornado == 3.0.1
      - websocket_client == 0.11.0
      - Werkzeug == 0.8.3
      - wsgiref == 0.1.2
      - WTForms == 1.0.5


VIRL_CORE:
  pip.installed:
    - order: 5
    - upgrade: True
    - use_wheel: True
    - no_index: True
    - no_deps: True
    - find_links: "file:///tmp/stdfiles"
    {% if grains['cml?'] == True %}
    - name: CML_CORE
    {% else %}
    - name: VIRL_CORE
    {% endif %}
  cmd.wait:
    - names:
    {% if grains['cml?'] == True %}
      - virl_config lsb-links
    {% else %}
      - crudini --set /usr/local/lib/python2.7/dist-packages/virl_pkg_data/conf/builtin.cfg orchestration network_security_groups False
    {% endif %}
      - /usr/local/bin/virl_config update --global
      - crudini --set /etc/virl/virl.cfg env virl_openstack_password {{ password }}
      - crudini --set /etc/virl/virl.cfg env virl_openstack_service_token {{ keystone_service_token }}
      - crudini --set /etc/virl/virl.cfg env virl_std_port {{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_url http://localhost:{{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_port {{ uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_url http://localhost:{{ uwmport }}
      - /usr/local/bin/virl_uwm_server init -A http://127.0.1.1:5000/v2.0 -u uwmadmin -p {{ uwmpass }} -U uwmadmin -P {{ uwmpass }} -T uwmadmin
    - watch:
      - pip: VIRL_CORE

virl-std:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pip: VIRL_CORE

virl-uwm:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pip: VIRL_CORE
