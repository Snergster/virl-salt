{% set proxy = salt['grains.get']('proxy', False) %}
{% set cml = salt['grains.get']('cml', False) %}
{% set cinder_enabled = salt['grains.get']('cinder_enabled', False) %}
{% set password = salt['grains.get']('password', 'password') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'password') %}
{% set stdport = salt['grains.get']('virl_webservices', '19399') %}
{% set uwmport = salt['grains.get']('virl_user_management', '19400') %}
{% set uwmpass = salt['grains.get']('uwmadmin_password', 'password') %}
{% set virl_type = salt['grains.get']('virl_type', 'stable') %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set httpproxy = salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/') %}

/var/cache/virl/std:
  file.recurse:
    - order: 1
    - user: virl
    - group: virl
    - file_mode: 755
    - source: "salt://std/{{venv}}/"


std_init:
  file.managed:
    - order: 3
    - name: /etc/init.d/virl-std
    - source: "salt://files/virl-std.init"
    - mode: 0755

/etc/virl directory:
  file.directory:
    - name: /etc/virl
    - dir_mode: 755

/etc/virl/common.cfg:
  file.touch:
    - require:
      - file: /etc/virl directory

std docs:
  archive:
    - extracted
    - name: /var/www/doc/
    - source: "salt://std/{{venv}}/doc/html_ext.tar.gz"
    - source_hash: md5=9ec5c0249e103e83e9c79fcfa8cfc19d
    - archive_format: tar
    - tar_options: xz
    - if_missing: /var/www/doc/index.html

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
{% if proxy == true %}
    - proxy: {{  httpproxy }}
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
    - pre_releases: True
    - no_deps: True
    - find_links: "file:///var/cache/virl/std"
    {% if cml == True %}
    - name: CML_CORE
    {% else %}
    - name: VIRL_CORE
    {% endif %}
  cmd.wait:
    - names:
    {% if cml == True %}
      - virl_config lsb-links
    {% else %}
      - crudini --set /usr/local/lib/python2.7/dist-packages/virl_pkg_data/conf/builtin.cfg orchestration network_security_groups False
      - crudini --set /usr/local/lib/python2.7/dist-packages/virl_pkg_data/conf/builtin.cfg orchestration network_custom_floating_ip True
      - crudini --set /etc/virl/common.cfg orchestration network_security_groups False
      - crudini --set /etc/virl/common.cfg orchestration network_custom_floating_ip True
    {% if cinder_enabled == True %}
      - crudini --set /usr/local/lib/python2.7/dist-packages/virl_pkg_data/conf/builtin.cfg orchestration volume_service True
      - crudini --set /etc/virl/common.cfg orchestration volume_service True
    {% else %}
      - crudini --set /usr/local/lib/python2.7/dist-packages/virl_pkg_data/conf/builtin.cfg orchestration volume_service False
      - crudini --set /etc/virl/common.cfg orchestration volume_service False
    {% endif %}
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
  cmd:
    - run
    - name: /usr/local/bin/virl_uwm_server init -A http://127.0.1.1:5000/v2.0 -u uwmadmin -p {{ uwmpass }} -U uwmadmin -P {{ uwmpass }} -T uwmadmin
    - onlyif: "test ! -e /var/local/virl/servers.db"
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
