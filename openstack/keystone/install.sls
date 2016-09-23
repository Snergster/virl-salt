{% from "virl.jinja" import virl with context %}

keystone no upstart:
  file.managed:
    - name: /etc/init/keystone.override
    - contents: |
        start on manual
        stop on manual

servername for apache:
  file.managed:
    - name: /etc/apache2/conf-available/servername.conf
    - contents: |
        ServerName '{{ virl.hostname }}.{{ virl.domain_name }}'

servername symlink:
  file.symlink:
    - name: /etc/apache2/conf-enabled/servername.conf
    - target: /etc/apache2/conf-available/servername.conf
    - require:
      - file: servername for apache

keystone die die:
  service.dead:
    - name: keystone

apache2 also needs to die die:
  service.dead:
    - name: apache2

waiting patiently for apache:
  module.run:
    - name: test.sleep
    - length: 10

{% if 'xenial' in salt['grains.get']('oscodename') %}

keystone-pkgs:
  pkg.installed:
    - aggregate: False
    - name: keystone
  service.dead:
    - name: keystone
  cmd.run:
    - names: 
      - systemctl stop keystone
      - systemctl disable keystone

apache2 installing:
  pkg.installed:
    - names:
      - apache2
      - libapache2-mod-wsgi
      - memcached
  service.dead:
    - names:
      - apache2
      - keystone
  cmd.run:
    - name: service apache2 restart
    - require:
      - service: keystone die die
      - module: waiting patiently for apache
  pip.installed:
  {% if virl.proxy %}
    - proxy: {{ virl.http_proxy }}
  {% endif %}
    - names:
      - python-memcached

install openstackclient:
  pkg.installed:
    - aggregate: False
    - name: python-openstackclient

{% else %}

keystone-pkgs:
  pkg.installed:
    - aggregate: False
    - names:
      - keystone
      - apache2
      - libapache2-mod-wsgi
      - memcached
  service.dead:
    - names:
      - apache2
      - keystone
  cmd.run:
    - name: service apache2 restart
    - require:
      - service: keystone die die
      - module: waiting patiently for apache
  pip.installed:
  {% if virl.proxy %}
    - proxy: {{ virl.http_proxy }}
  {% endif %}
    - names:
      - python-memcached

{% endif %}

{% if virl.mitaka %}

{% for basepath in [
    'keystone+catalog+backends+sql.py',
] %}

{% set realpath = '/usr/lib/python2.7/dist-packages/' + basepath.replace('+', '/') %}
{{ realpath }}:
  file.managed:
    - source: salt://openstack/keystone/files/mitaka/{{ basepath }}
  cmd.wait:
    - names:
      - python -m compileall {{ realpath }}
    - watch:
      - file: {{ realpath }}
    - require:
      - pkg: keystone-pkgs

{% endfor %}

{% endif %}

/etc/keystone/keystone.conf:
  file.managed:
    - source: "salt://openstack/keystone/files/kilo.keystone.conf.jinja"
    - template: jinja
    - require:
      - pkg: keystone-pkgs

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

apache die:
  cmd.run:
    - name: 'service apache2 stop'

apache die2:
  cmd.run:
    - onfail: 
      - cmd: apache die
    - name: 'service apache2 stop'

apache restart keystone:
  cmd.run:
    - name: 'service apache2 start'

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
      - 'service apache2 restart'
      - 'sleep 15'

