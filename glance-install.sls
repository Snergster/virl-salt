{% set glancepassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set mypassword = salt['grains.get']('mysql_password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}

glance-pkgs:
  pkg.installed:
    - order: 1
    - refresh: False
    - names:
      - glance

glance-api:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: 'image_cache_dir = /var/lib/glance/image-cache/'
    - repl: '#image_cache_dir = /var/lib/glance/image-cache/'

glance-reg:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - pattern: 'image_cache_dir = /var/lib/glance/image-cache/'
    - repl: '#image_cache_dir = /var/lib/glance/image-cache/'

glance-api-olddb:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: 'sqlite_db = /var/lib/glance/glance.sqlite'
    - repl: '#sqlite_db = /var/lib/glance/glance.sqlite'

glance-reg-olddb:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - pattern: 'sqlite_db = /var/lib/glance/glance.sqlite'
    - repl: '#sqlite_db = /var/lib/glance/glance.sqlite'

glance-api-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ mypassword }}@127.0.0.1/glance'

glance-reg-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ mypassword }}@127.0.0.1/glance'

glance-api-rabbitpass:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_password'
    - value: '{{ rabbitpassword }}'


glance-api-tenname:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: 'admin_tenant_name = %SERVICE_TENANT_NAME%'
    - repl: 'admin_tenant_name = service'

glance-reg-tenname:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - pattern: 'admin_tenant_name = %SERVICE_TENANT_NAME%'
    - repl: 'admin_tenant_name = service'

glance-api-user:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: 'admin_user = %SERVICE_USER%'
    - repl: 'admin_user = glance'

glance-reg-user:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - pattern: 'admin_user = %SERVICE_USER%'
    - repl: 'admin_user = glance'

glance-api-pass:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: 'admin_password = %SERVICE_PASSWORD%'
    - repl: 'admin_password = {{ ospassword }}'

glance-reg-pass:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - pattern: 'admin_password = %SERVICE_PASSWORD%'
    - repl: 'admin_password = {{ ospassword }}'

glance-api-flavor:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: '#flavor='
    - repl: 'flavor=keystone'

glance-reg-flavor:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - pattern: '#flavor='
    - repl: 'flavor=keystone'


glance db-sync:
  cmd.run:
    - name: su -s /bin/sh -c "glance-manage db_sync" glance

db-restart:
  cmd.run:
    - order: last
    - names:
      - service glance-registry restart
      - service glance-api restart
    - require:
      - pkg: glance
