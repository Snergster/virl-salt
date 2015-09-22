{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}

keystone-pkgs:
  pkg.installed:
    - names:
      - keystone
{% if kilo %}
      - apache2
      - libapache2-mod-wsgi
      - python-openstackclient
      - memcached
      - python-memcache
{% endif %}

/etc/keystone/keystone.conf:
  file.managed:
    {% if masterless %}
    - source: file:///srv/salt/openstack/keystone/files/keystone.conf.jinja
    {% else %}
    - source: "salt://openstack/keystone/files/keystone.conf.jinja"
    {% endif %}
    - template: jinja
    - require:
      - pkg: keystone-pkgs

{% if kilo %}
/usr/local/bin/admin-openrc:
  file.managed:
    {% if masterless %}
    - source: file:///srv/salt/openstack/keystone/files/admin-openrc.jinja
    {% else %}
    - source: "salt://openstack/keystone/files/admin-openrc.jinja"
    {% endif %}
    - mode: 0755
    - template: jinja
    - require:
      - pkg: keystone-pkgs

/etc/apache2/sites-available/wsgi-keystone.conf:
  file.managed:
    - source: "salt://openstack/keystone/files/wsgi-keystone.conf"
    - mode: 0644
    - require:
      - pkg: keystone-pkgs

/etc/apache2/sites-available/wsgi-keystone.conf symlink:
   file.symlink:
     - name: /etc/apache2/sites-enabled/wsgi-keystone.conf
     - target: /etc/apache2/sites-available/wsgi-keystone.conf

/var/www/cgi-bin/keystone.py:
  file.managed:
    - source: "salt://openstack/keystone/files/keystone.py"
    - mode: 0755
    - dir_mode: 0755
    - user: keystone
    - group: keystone
    - require:
      - pkg: keystone-pkgs

keystone memcached:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'memcache'
    - parameter: 'servers'
    - value: 'localhost:11211'
    - require:
      - file: /etc/keystone/keystone.conf

keystone token provider:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'token'
    - parameter: 'provider'
    - value: 'keystone.token.providers.uuid.Provider'
    - require:
      - file: /etc/keystone/keystone.conf

keystone token driver:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'token'
    - parameter: 'driver'
    - value: 'keystone.token.persistence.backends.memcache.Token'
    - require:
      - file: /etc/keystone/keystone.conf

keystone revoke driver:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'revoke'
    - parameter: 'driver'
    - value: 'keystone.token.persistence.backends.memcache.Revoke'
    - require:
      - file: /etc/keystone/keystone.conf

apache restart keystone:
  cmd.run:
    - names:
      - 'service apache2 restart'
{% endif %}

keystone db-sync:
  cmd.run:
    - name: su -s /bin/sh -c "keystone-manage db_sync" keystone
    - require:
      - pkg: keystone-pkgs
      - file: /etc/keystone/keystone.conf

/usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1:
  cron.present:
    - user: root
    - hour: 5
    - require:
      - cmd: keystone db-sync

key-db-sync:
  cmd.run:
    - names:
      - 'service keystone restart'
      - 'sleep 15'
