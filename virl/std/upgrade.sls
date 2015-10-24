{% set cml = salt['grains.get']('cml', False) %}
{% set virl_type = salt['grains.get']('virl_type', 'stable') %}
{% set uwmpassword = salt['pillar.get']('virl:uwmadmin_password', salt['grains.get']('uwmadmin_password', 'password')) %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set std_ver_fixed = salt['pillar.get']('behave:std_ver_fixed', salt['grains.get']('std_ver_fixed', False)) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set stdport = salt['pillar.get']('virl:virl_webservices', salt['grains.get']('virl_webservices', '19399')) %}
{% set std_ver = salt['pillar.get']('behave:std_ver', salt['grains.get']('std_ver', '0.10.10.18')) %}
{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set cinder_enabled = salt['pillar.get']('virl:cinder_enabled', salt['grains.get']('cinder_enabled', False)) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set serstart = salt['pillar.get']('virl:start_of_serial_port_range', salt['grains.get']('start_of_serial_port_range', '17000')) %}
{% set serend = salt['pillar.get']('virl:end_of_serial_port_range', salt['grains.get']('end_of_serial_port_range', '18000')) %}
{% set ank_live = salt['pillar.get']('virl:ank_live', salt['grains.get']('ank_live', '19402')) %}
{% set virl_webmux = salt['pillar.get']('virl:virl_webmux', salt['grains.get']('virl_webmux', '19403')) %}
{% set topology_editor_port = salt['pillar.get']('virl:ank', salt['grains.get']('ank', '19401')) %}
{% set web_editor = salt['pillar.get']('virl:web_editor', salt['grains.get']('web_editor', False)) %}
{% set fdns = salt['pillar.get']('virl:first_nameserver', salt['grains.get']('first_nameserver', '8.8.8.8' )) %}
{% set sdns = salt['pillar.get']('virl:second_nameserver', salt['grains.get']('second_nameserver', '8.8.4.4' )) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}


/var/cache/virl/std:
  file.recurse:
    {% if std_ver_fixed %}
    - name: /var/cache/virl/fixed/std
    - source: "salt://fixed/std"
    {% else %}
      {% if cml %}
    - source: "salt://cml/std/{{venv}}/"
    - name: /var/cache/virl/std
      {% else %}
    - source: "salt://std/{{venv}}/"
    - name: /var/cache/virl/std
      {% endif %}
    {% endif %}
    - clean: true
    - show_diff: False
    - user: virl
    - group: virl
    - file_mode: 755


uwm_init:
  file.managed:
    - name: /etc/init.d/virl-uwm
    - source: "salt://virl/std/files/virl-uwm.init"
    - mode: 0755

std_init:
  file.managed:
    - name: /etc/init.d/virl-std
    - source: "salt://virl/std/files/virl-std.init"
    - mode: 0755

{% if not cml %}

std doc cleaner:
  file.directory:
    - name: /var/www/doc
    - clean: True

{% endif %}

std docs:
  archive:
    - extracted
    - name: /var/www/doc/
    {% if cml %}
    - source: "salt://cml/std/{{venv}}/doc/html_ext.tar.gz"
    {% else %}
    - source: "salt://std/{{venv}}/doc/html_ext.tar.gz"
    {% endif %}
{#    - source_hash: md5=d44c6584a80aea1af377868636ac0383 #}
    - archive_format: tar
    - if_missing: /var/www/doc/index.html
{% if not cml %}
    - require:
      - file: std doc cleaner
{% endif %}

#   {% if not cml %}
virl_webmux_init:
  file.managed:
    - name: /etc/init/virl-webmux.conf
    - source: "salt://virl/std/files/virl-webmux.conf"
    - mode: 0755

# std_prereq_webmux:
#   pip.installed:
#   {% if proxy == true %}
#     - proxy: {{ http_proxy }}
#   {% endif %}
#     - require:
#       - pkg: std prereq pkgs
#     - names:
#       - Twisted >= 13.2.0
#       - parse >= 1.4.1
#       - stuf >= 0.9.4
#       - txsockjs >= 1.2.1
#       - zope.interface >= 4.1.0
#       - SQLObject >= 1.5.1
#       - service_identity
#       - docker-py >= 1.3.1
#       - lxml >= 3.4.1
#   {% endif %}

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
    - makedirs: true
    - mode: 0644


/etc/rc2.d/S98virl-std:
  file.symlink:
    - target: /etc/init.d/virl-std
    - mode: 0755

/etc/rc2.d/S98virl-uwm:
  file.symlink:
    - target: /etc/init.d/virl-uwm
    - mode: 0755

ifb modprobe:
  file.append:
    - name: /etc/modules
    - text: ifb numifbs=32
    - unless: grep ifb /etc/modules
  cmd.run:
    - name: modprobe ifb numifbs=32
    - unless: grep "^ifb" /proc/modules

std uwm port replace:
  file.replace:
      - name: /var/www/html/index.html
      - pattern: :\d{2,}"
      - repl: :{{ uwmport }}"
      - unless: grep {{ uwmport }} /var/www/html/index.html
{% if kilo %}
std nova-compute serial:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'serial_console'
    - parameter: 'port_range'
    - value: '{{ serstart }}:{{ serend }}'

{% else %}
std nova-compute serial:
  openstack_config.present:
    - filename: /etc/nova/nova-compute.conf
    - section: 'libvirt'
    - parameter: 'serial_port_range'
    - value: '{{ serstart }}:{{ serend }}'

{% endif %}

# std_prereq:
#   pip.installed:
# {% if proxy == true %}
#     - proxy: {{ http_proxy }}
# {% endif %}
#     - names:
#       - ipaddr >= 2.1.11
#       - flask-sqlalchemy >= 2.0
#       - Flask >= 0.10.1
#       - Flask_Login == 0.2.11
#       - Flask_RESTful >= 0.3.2
#       - Flask_WTF >= 0.11
#       - Flask_Breadcrumbs >= 0.3.0
#       - Flask_Swagger >= 0.2.10
#       - itsdangerous >= 0.24
#       - Jinja2 >= 2.7.3
#       - lxml >= 3.4.1
#       - MarkupSafe >= 0.23
#       - mock >= 1.0.1
#       - paramiko >= 1.15.2
#       - pycrypto >= 2.6.1
#       - Pygments
#       - requests == 2.7.0
#       - simplejson >= 3.6.5
#       - sqlalchemy == 0.9.9
#       - websocket_client >= 0.26.0
#       - Werkzeug >= 0.10.1
#       - wsgiref
#       - WTForms >= 2.0.2
# {% if kilo %}
#       - tornado >= 3.2.2
# {% else %}
#       - tornado >= 3.2.2, < 4.0.0
# {% endif %}
#       - require:
#         - pkg: 'std prereq pkgs'

VIRL_CORE:
  pip.installed:
    - use_wheel: True
    - no_index: True
    - pre_releases: True
    - no_deps: True
    {% if cml %}
     {% if std_ver_fixed %}
    - name: CML_CORE  == {{ std_ver }}
    - find_links: "file:///var/cache/virl/fixed/std"
     {% else %}
    - find_links: "file:///var/cache/virl/std"
    - name: CML_CORE
     {% endif %}
    {% else %}
    {% if std_ver_fixed %}
    - name: VIRL_CORE  == {{ std_ver }}
    - find_links: "file:///var/cache/virl/fixed/std"
    {% else %}
    - name: VIRL_CORE
    - find_links: "file:///var/cache/virl/std"
    - upgrade: True
    {% endif %}
    {% endif %}
  service.dead:
    - names:
      - virl-std
      - virl-uwm
    - prereq:
      - pip: VIRL_CORE
  cmd.run:
    - names:
     {% if cml %}
      - echo /usr/local/bin/virl_config lsb-links | at now + 1 min
     {% else %}
      - crudini --set /usr/local/lib/python2.7/dist-packages/virl_pkg_data/conf/builtin.cfg orchestration network_security_groups False
      - crudini --set /usr/local/lib/python2.7/dist-packages/virl_pkg_data/conf/builtin.cfg orchestration network_custom_floating_ip True
      - crudini --set /etc/virl/common.cfg orchestration network_security_groups False
      - crudini --set /etc/virl/common.cfg orchestration network_custom_floating_ip True
     {% endif %}
     {% if cinder_enabled %}
      - crudini --set /usr/local/lib/python2.7/dist-packages/virl_pkg_data/conf/builtin.cfg orchestration volume_service True
      - crudini --set /etc/virl/common.cfg orchestration volume_service True
     {% else %}
      - crudini --set /usr/local/lib/python2.7/dist-packages/virl_pkg_data/conf/builtin.cfg orchestration volume_service False
      - crudini --set /etc/virl/common.cfg orchestration volume_service False
     {% endif %}
      - /usr/local/bin/virl_config update --global
      - crudini --set /etc/virl/virl.cfg env virl_openstack_password {{ uwmpassword }}
      - crudini --set /etc/virl/virl.cfg env virl_openstack_service_token {{ ks_token }}
      - crudini --set /etc/virl/virl.cfg env virl_std_port {{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_url http://localhost:{{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_port {{ uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_url http://localhost:{{ uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_user_name uwmadmin
      - crudini --set /etc/virl/virl.cfg env virl_std_password {{ uwmpassword }}
      - crudini --set /etc/virl/virl.cfg 'new-project-networks' snat_net_dns {{ fdns }}
      - crudini --set /etc/virl/virl.cfg 'new-project-networks' snat_net_dns2 {{ sdns }}
      - crudini --set /etc/virl/virl.cfg 'new-project-networks' mgmt_net_dns {{ fdns }}
      - crudini --set /etc/virl/virl.cfg 'new-project-networks' mgmt_net_dns2 {{ sdns }}
      - crudini --set /etc/virl/virl.cfg env virl_webmux_port {{ virl_webmux }}
      - crudini --set /etc/virl/common.cfg host webmux_port {{ virl_webmux }}
      - crudini --set /etc/virl/common.cfg host ank_live_port {{ ank_live }}

ank_live_port change:
  cmd.run:
    - name: 'crudini --set /etc/virl/common.cfg host ank_live_port {{ ank_live }}'


web editor alpha:
{% if web_editor %}
  cmd.run:
    - name: 'crudini --set /etc/virl/common.cfg host topology_editor_port {{ topology_editor_port }}'
{% else %}
  file.replace:
    - name: /etc/virl/common.cfg
    - pattern: '^topology_editor_port.*'
    - repl: ''
{% endif %}
    - require:
      - pip: VIRL_CORE

webmux_port change:
  cmd.run:
    - names:
      - crudini --set /etc/virl/virl.cfg env virl_webmux_port {{ virl_webmux }}
      - crudini --set /etc/virl/common.cfg host webmux_port {{ virl_webmux }}
      - service virl-webmux restart

uwmadmin change:
  cmd.run:
    - names:
     {% if cml %}
      - sleep 65
     {% endif %}
      - '/usr/local/bin/virl_uwm_server set-password -u uwmadmin -p {{ uwmpassword }} -P {{ uwmpassword }}'
      - crudini --set /etc/virl/virl.cfg env virl_openstack_password {{ uwmpassword }}
      - crudini --set /etc/virl/virl.cfg env virl_std_password {{ uwmpassword }}
    - onlyif: 'test -e /var/local/virl/servers.db'

virl init:
  cmd:
    - run
    - name: /usr/local/bin/virl_uwm_server init -A http://127.0.1.1:5000/v2.0 -u uwmadmin -p {{ uwmpassword }} -U uwmadmin -P {{ uwmpassword }} -T uwmadmin
    - onlyif: 'test ! -e /var/local/virl/servers.db'

virl init second:
  cmd:
    - run
    - name: /usr/local/bin/virl_uwm_server init -A http://127.0.1.1:5000/v2.0 -u uwmadmin -p {{ uwmpassword }} -U uwmadmin -P {{ uwmpassword }} -T uwmadmin
    - onfail:
      - cmd: uwmadmin change

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
