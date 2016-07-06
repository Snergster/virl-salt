{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set glancepassword = salt['pillar.get']('virl:glancepassword', salt['grains.get']('password', 'password')) %}
{% set rabbitpassword = salt['pillar.get']('virl:rabbitpassword', salt['grains.get']('password', 'password')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', true)) %}
{% set mitaka = salt['pillar.get']('virl:mitaka', salt['grains.get']('mitaka', false)) %}

glance-pkgs:
  pkg.installed:
    - refresh: False
    - names:
      - glance


oslo glance prereq:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - require:
      - pkg: glance-pkgs
    - names:
{% if mitaka %}
      - oslo.i18n
{% else %}
      - oslo.i18n == 1.6.0
{% endif %}


glance-api user token:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: '#use_user_token = True'
{% if mitaka %}
    - repl: 'use_user_token = True'
{% else %}
    - repl: 'use_user_token = False'
{% endif %}
    - require:
      - pkg: glance-pkgs

glance-api admin user:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: '#admin_user = None'
    - repl: 'admin_user = glance'
    - require:
      - pkg: glance-pkgs

glance-api admin password uncomment:
  file.uncomment:
    - name: /etc/glance/glance-api.conf
    - regex: 'admin_password = None'
    - onlyif: grep '#admin_password = None' /etc/glance/glance-api.conf
    - require:
      - pkg: glance-pkgs

glance-api admin password:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: '^admin_password = .*'
    - repl: 'admin_password = {{glancepassword}}'
    - require:
      - pkg: glance-pkgs


glance-api admin tenant:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: '#admin_tenant_name = None'
    - repl: 'admin_tenant_name = service'
    - require:
      - pkg: glance-pkgs

glance-api auth url:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: '#auth_url = None'
    - repl: 'auth_url = http://127.0.1.1:35357/v2.0'
    - require:
      - pkg: glance-pkgs



glance-api:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - pattern: 'image_cache_dir = /var/lib/glance/image-cache/'
    - repl: '#image_cache_dir = /var/lib/glance/image-cache/'
    - require:
      - pkg: glance-pkgs

glance-reg:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - pattern: 'image_cache_dir = /var/lib/glance/image-cache/'
    - repl: '#image_cache_dir = /var/lib/glance/image-cache/'
    - require:
      - pkg: glance-pkgs

glance-api-olddb:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - pattern: 'sqlite_db = /var/lib/glance/glance.sqlite'
    - repl: '#sqlite_db = /var/lib/glance/glance.sqlite'
    - require:
      - pkg: glance-pkgs

glance-reg-olddb:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - pattern: 'sqlite_db = /var/lib/glance/glance.sqlite'
    - repl: '#sqlite_db = /var/lib/glance/glance.sqlite'
    - require:
      - pkg: glance-pkgs

glance-api-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ mypassword }}@{{ controllerip }}/glance'
    - require:
      - pkg: glance-pkgs

glance-reg-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ mypassword }}@{{ controllerip }}/glance'
    - require:
      - pkg: glance-pkgs

glance-api-rabbitpass:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_password'
    - value: '{{ rabbitpassword }}'
    - require:
      - pkg: glance-pkgs


glance-api-tenname:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_tenant_name'
    - value: 'service'

glance-reg-tenname:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_tenant_name'
    - value: 'service'
    - require:
      - pkg: glance-pkgs

glance-api-user:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_user'
    - value: 'glance'
    - require:
      - pkg: glance-pkgs

glance-reg-user:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_user'
    - value: 'glance'
    - require:
      - pkg: glance-pkgs

glance-api-pass:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_password'
    - value: {{ ospassword }}
    - require:
      - pkg: glance-pkgs


glance-reg-pass:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_password'
    - value: {{ ospassword }}
    - require:
      - pkg: glance-pkgs

glance-api-flavor:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'paste_deploy'
    - parameter: 'flavor'
    - value: 'keystone'
    - require:
      - pkg: glance-pkgs

glance-reg-flavor:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'paste_deploy'
    - parameter: 'flavor'
    - value: 'keystone'
    - require:
      - pkg: glance-pkgs


glance-api-user-token:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'DEFAULT'
    - parameter: 'use_user_token'
{% if mitaka %}
    - value: 'True'
{% else %}
    - value: 'False'
{% endif %}
    - require:
      - pkg: glance-pkgs


glance db-sync:
  cmd.run:
    - order: last
    - name: su -s /bin/sh -c "glance-manage db_sync" glance

glance db-restart:
  cmd.run:
    - order: last
    - names:
      - /usr/sbin/service glance-registry restart | at now + 2 min
      - /usr/sbin/service glance-api restart | at now + 2 min
    - require:
      - pkg: glance
