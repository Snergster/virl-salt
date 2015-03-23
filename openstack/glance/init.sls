{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set glancepassword = salt['pillar.get']('virl:glancepassword', salt['grains.get']('password', 'password')) %}
{% set rabbitpassword = salt['pillar.get']('virl:rabbitpassword', salt['grains.get']('password', 'password')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}

glance-pkgs:
  pkg.installed:
    - refresh: False
    - names:
      - glance

glance-api:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: 'image_cache_dir = /var/lib/glance/image-cache/'
    - repl: '#image_cache_dir = /var/lib/glance/image-cache/'
    - require:
      - pkg: glance-pkgs

glance-reg:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - pattern: 'image_cache_dir = /var/lib/glance/image-cache/'
    - repl: '#image_cache_dir = /var/lib/glance/image-cache/'
    - require:
      - pkg: glance-pkgs

glance-api-olddb:
  file.replace:
    - name: /etc/glance/glance-api.conf
    - pattern: 'sqlite_db = /var/lib/glance/glance.sqlite'
    - repl: '#sqlite_db = /var/lib/glance/glance.sqlite'
    - require:
      - pkg: glance-pkgs

glance-reg-olddb:
  file.replace:
    - name: /etc/glance/glance-registry.conf
    - pattern: 'sqlite_db = /var/lib/glance/glance.sqlite'
    - repl: '#sqlite_db = /var/lib/glance/glance.sqlite'
    - require:
      - pkg: glance-pkgs

glance-api-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ mypassword }}@{{ controllerip }}/glance'
    - require:
      - pkg: glance-pkgs

glance-reg-conn:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://glance:{{ mypassword }}@{{ controllerip }}/glance'
    - require:
      - pkg: glance-pkgs

glance-api-rabbitpass:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_password'
    - value: '{{ rabbitpassword }}'
    - require:
      - pkg: glance-pkgs


glance-api-tenname:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_tenant_name'
    - value: 'service'

glance-reg-tenname:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_tenant_name'
    - value: 'service'
    - require:
      - pkg: glance-pkgs

glance-api-user:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_user'
    - value: 'glance'
    - require:
      - pkg: glance-pkgs

glance-reg-user:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_user'
    - value: 'glance'
    - require:
      - pkg: glance-pkgs

glance-api-pass:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_password'
    - value: {{ ospassword }}
    - require:
      - pkg: glance-pkgs


glance-reg-pass:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_password'
    - value: {{ ospassword }}
    - require:
      - pkg: glance-pkgs

glance-api-flavor:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - section: 'paste_deploy'
    - parameter: 'flavor'
    - value: 'keystone'
    - require:
      - pkg: glance-pkgs

glance-reg-flavor:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - section: 'paste_deploy'
    - parameter: 'flavor'
    - value: 'keystone'
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
