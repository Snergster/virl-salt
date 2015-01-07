{% set cml = salt['grains.get']('cml', False) %}
{% set virl_type = salt['grains.get']('virl_type', 'stable') %}
{% set uwmpassword = salt['pillar.get']('virl:uwmadmin_password', salt['grains.get']('uwmadmin_password', 'password')) %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set http_proxy = salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/') %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set std_ver_fixed = salt['pillar.get']('behave:std_ver_fixed', salt['grains.get']('std_ver_fixed', False)) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set stdport = salt['pillar.get']('virl:virl_webservices', salt['grains.get']('virl_webservices', '19399')) %}
{% set std_ver = salt['pillar.get']('behave:std_ver', salt['grains.get']('std_ver', '0.10.10.18')) %}
{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set cinder_enabled = salt['pillar.get']('virl:cinder_enabled', salt['grains.get']('cinder_enabled', False)) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

{% if not masterless %}
/var/cache/virl/std:
  file.recurse:
    - order: 1
    - user: virl
    - group: virl
    - file_mode: 755
    - source: "salt://std/{{venv}}/"

uwm_init:
  file.managed:
    - order: 4
    - name: /etc/init.d/virl-uwm
    - source: "salt://files/virl-uwm.init"
    - mode: 0755

std_init:
  file.managed:
    - order: 3
    - name: /etc/init.d/virl-std
    - source: "salt://files/virl-std.init"
    - mode: 0755

std docs:
  archive:
    - extracted
    - name: /var/www/doc/
    - source: "salt://std/{{venv}}/doc/html_ext.tar.gz"
    - source_hash: md5=d44c6584a80aea1af377868636ac0383
    - archive_format: tar
    - tar_options: xz
    - if_missing: /var/www/doc/index.html

{% else %}

std_init local:
  file.managed:
    - order: 3
    - name: /etc/init.d/virl-std
    - source: "file:///srv/salt/virl/std/files/virl-std.init"
    - source_hash: md5=ddc96d3ca3c9e00f5e589077e92fb782
    - mode: 0755

uwm_init local:
  file.managed:
    - order: 3
    - name: /etc/init.d/virl-uwm
    - source: "file:///srv/salt/virl/std/files/virl-uwm.init"
    - source_hash: md5=70a05f8156cb1a9b9a7668d043558668
    - mode: 0755

std docs local:
  archive:
    - extracted
    - name: /var/www/doc/
    - source: "file:///srv/salt/virl/std/files/html_ext.tar.gz"
    - source_hash: md5=d44c6584a80aea1af377868636ac0383
    - archive_format: tar
    - tar_options: xz
    - if_missing: /var/www/doc/index.html


{% endif %}

/etc/virl directory:
  file.directory:
    - name: /etc/virl
    - dir_mode: 755

/etc/virl/common.cfg:
  file.touch:
    - require:
      - file: /etc/virl directory
    - onlyif: 'test ! -e /etc/virl/common.cfg'


/etc/virl/virl.cfg:
  file.managed:
    - replace: false
    - order: 3
    - makedirs: true
    - mode: 0644


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
    - proxy: {{ http_proxy }}
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
    - use_wheel: True
    - no_index: True
    - pre_releases: True
    - no_deps: True
    - find_links: "file:///var/cache/virl/std"
    {% if cml == True %}
    - name: CML_CORE
    {% else %}
    {% if std_ver_fixed == True %}
    - name: VIRL_CORE  == {{ std_ver }}
    {% else %}
    - name: VIRL_CORE
    - upgrade: True
    {% endif %}
    {% endif %}
  service.dead:
    - names:
      - virl-std
      - virl-uwm
    - prereq:
      - pip: VIRL_CORE
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
      - crudini --set /etc/virl/virl.cfg env virl_openstack_password {{ ospassword }}
      - crudini --set /etc/virl/virl.cfg env virl_openstack_service_token {{ ks_token }}
      - crudini --set /etc/virl/virl.cfg env virl_std_port {{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_url http://localhost:{{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_port {{ uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_url http://localhost:{{ uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_user_name uwmadmin
      - crudini --set /etc/virl/virl.cfg env virl_std_password {{ uwmpassword }}
    - onchanges:
      - pip: VIRL_CORE

virl init:
  cmd:
    - run
    - name: /usr/local/bin/virl_uwm_server init -A http://127.0.1.1:5000/v2.0 -u uwmadmin -p {{ uwmpassword }} -U uwmadmin -P {{ uwmpassword }} -T uwmadmin
    - onlyif: 'test ! -e /var/local/virl/servers.db'


virl-std:
  service:
    - running
    - order: last
    - enable: True
    - restart: True

virl-uwm:
  service:
    - running
    - order: last
    - enable: True
    - restart: True
