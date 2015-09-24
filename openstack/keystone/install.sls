{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}

{% if kilo %}
keystone no upstart:
  file.managed:
    - name: /etc/init/keystone.override
    - contents: |
        start on manual
        stop on manual
{% endif %}

keystone-pkgs:
  pkg.installed:
    - names:
      - keystone
{% if kilo %}
      - apache2
      - libapache2-mod-wsgi
      - memcached
  service.dead:
    - name: keystone
  cmd.run:
    - name: service apache2 restart
    - require:
      - service: keystone
  pip.installed:
  {% if proxy == true %}
    - proxy: {{ http_proxy }}
  {% endif %}
    - names:
      - python-memcached
{% endif %}

/etc/keystone/keystone.conf:
  file.managed:
    {% if kilo %}
    - source: "salt://openstack/keystone/files/kilo.keystone.conf.jinja"
    {% else %}
    - source: "salt://openstack/keystone/files/keystone.conf.jinja"
    {% endif %}
    - template: jinja
    - require:
      - pkg: keystone-pkgs

{% if kilo %}
/usr/local/bin/admin-openrc:
  file.managed:
    - source: "salt://openstack/keystone/files/admin-openrc.jinja"
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

/var/www/cgi-bin/keystone/main:
  file.managed:
    - source: "salt://openstack/keystone/files/keystone.py"
    - mode: 0755
    - dir_mode: 0755
    - makedirs: True
    - user: keystone
    - group: keystone
    - require:
      - pkg: keystone-pkgs

/var/www/cgi-bin/keystone/admin:
  file.managed:
    - source: "salt://openstack/keystone/files/keystone.py"
    - mode: 0755
    - dir_mode: 0755
    - makedirs: True
    - user: keystone
    - group: keystone
    - require:
      - pkg: keystone-pkgs

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
    {% if kilo %}
      - 'service apache2 restart'
    {% else %}
      - 'service keystone restart'
    {% endif %}
      - 'sleep 15'

