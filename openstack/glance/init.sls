{% from "virl.jinja" import virl with context %}

glance-pkgs:
  pkg.installed:
    - refresh: False
    - names:
      - glance


oslo glance prereq:
  pip.installed:
{% if virl.proxy %}
    - proxy: {{ virl.http_proxy }}
{% endif %}
    - require:
      - pkg: glance-pkgs
    - names:
{% if virl.mitaka %}
      - oslo.i18n
{% else %}
      - oslo.i18n == 1.6.0
{% endif %}


glance-api-workers:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'DEFAULT'
    - parameter: 'workers'
    - value: '{{ worker_count('glance-api') }}'

glance-reg-workers:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'DEFAULT'
    - parameter: 'workers'
    - value: '{{ worker_count('glance-registry') }}'


glance-api user token:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: '#use_user_token = True'
{% if virl.mitaka %}
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
    - repl: 'admin_password = {{ virl.ospassword }}'
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
    - repl: 'auth_url = http://127.0.1.1:35357/{{virl.keystone_auth_version}}'
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

{% if virl.mitaka %}

glance-api-conn:
  ini.options_present:
    - name: /etc/glance/glance-api.conf
    - sections:
        database:
          connection: 'mysql://glance:{{ virl.mypassword }}@{{ virl.controller_ip }}/glance'

{% else %}

glance-api-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ virl.mypassword }}@{{ virl.controller_ip }}/glance'
    - require:
      - pkg: glance-pkgs

{% endif %}

glance-reg-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ virl.mypassword }}@{{ virl.controller_ip }}/glance'
    - require:
      - pkg: glance-pkgs

glance-api-dbpool-size:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'max_pool_size'
    - value: '{{ db_pool.max_size }}'
    - require:
      - pkg: glance-pkgs

glance-reg-dbpool-size:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'max_pool_size'
    - value: '{{ db_pool.max_size }}'
    - require:
      - pkg: glance-pkgs

glance-api-dbpool-overflow:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'max_overflow'
    - value: '{{ db_pool.overflow }}'
    - require:
      - pkg: glance-pkgs

glance-reg-dbpool-overflow:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'max_overflow'
    - value: '{{ db_pool.overflow }}'
    - require:
      - pkg: glance-pkgs

glance-api-dbpool-idle:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'idle_timeout'
    - value: '{{ db_pool.idle_sec }}'
    - require:
      - pkg: glance-pkgs

glance-reg-dbpool-idle:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'idle_timeout'
    - value: '{{ db_pool.idle_sec }}'
    - require:
      - pkg: glance-pkgs

glance-api-rabbitpass:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_password'
    - value: '{{ virl.ospassword }}'
    - require:
      - pkg: glance-pkgs


glance-api-identityuri:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'keystone_authtoken'
    - parameter: 'identity_uri'
    - value: 'http://{{ virl.controller_ip }}:35357'

glance-reg-identityuri:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'keystone_authtoken'
    - parameter: 'identity_uri'
    - value: 'http://{{ virl.controller_ip }}:35357'


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
    - value: {{ virl.ospassword }}
    - require:
      - pkg: glance-pkgs


glance-reg-pass:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_password'
    - value: {{ virl.ospassword }}
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
{% if virl.mitaka %}
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
