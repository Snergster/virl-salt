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
      - ipaddr
      - flask-sqlalchemy
      - Flask
      - Flask_Login
      - Flask_RESTful
      - Flask_WTF
      - itsdangerous
      - Jinja2
      - lxml
      - MarkupSafe
      - mock
      - requests
      - paramiko
      - pycrypto
      - simplejson
      - sqlalchemy
      - tornado == 3.0.1
      - websocket_client
      - Werkzeug
      - wsgiref
      - WTForms 


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
    - watch:
      - pip: VIRL_CORE

virl init:
  cmd.wait:
    - name: /usr/local/bin/virl_uwm_server init -A http://127.0.1.1:5000/v2.0 -u uwmadmin -p {{ uwmpass }} -U uwmadmin -P {{ uwmpass }} -T uwmadmin
    - unless: ls /var/local/virl/users
    - watch:
      - pip: VIRL_CORE

virl-std:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pip: VIRL_CORE
      - cmd: virl init

virl-uwm:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pip: VIRL_CORE
      - cmd: virl init