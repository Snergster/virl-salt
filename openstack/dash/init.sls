{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set enable_horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', True)) %}
{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}

{% if cml %}
/srv/salt/virl/files/cmlweb.tar:
  file.managed:
    - source: 'salt://virl/files/cmlweb.tar'
    - mode: 755
    - user: virl
    - group: virl
    - require:
      - pkg: horizon-pkgs
      

apache overwrite:
  archive:
    - extracted
    - name: /var/www/html
    - source: file:///srv/salt/virl/files/cmlweb.tar
    - source_hash: md5=d67f85b69bc80bb1ac4e2592d20a4c83
    - archive_format: tar
    - onchanges:
      - file: apache dir remove

apache dir remove:
  file.absent:
    - name: /var/www/html
    - onchanges:
      - file: /srv/salt/virl/files/cmlweb.tar

{% else %}

/srv/salt/virl/files/virlweb.tar:
  file.managed:
    - source: 'salt://virl/files/virlweb.tar'
    - mode: 755
    - user: virl
    - group: virl
    - require:
      - pkg: horizon-pkgs


apache overwrite:
  archive:
    - extracted
    - name: /var/www/html
    - source: file:///srv/salt/virl/files/virlweb.tar
    - source_hash: md5=b1a24317d5937caeba82fbc049f5055f
    - archive_format: tar
    - onchanges:
      - file: apache dir remove


apache dir remove:
  file.absent:
    - name: /var/www/html
    - onchanges:
      - file: /srv/salt/virl/files/virlweb.tar
{% endif %}

{% if enable_horizon == True %}

horizon-pkgs:
  pkg.installed:
    - order: 1
    - refresh: False
    - names:
      - apache2
      - memcached
      - libapache2-mod-wsgi
      - openstack-dashboard

openstack-dashboard-ubuntu-theme:
  pkg.removed:
    - order: 2
    - purge: True

openstack-dash:
  file.append:
    - order: 3
    - name: /etc/apt/preferences.d/cisco-openstack
    - text: |
        Package: openstack-dashboard-ubuntu-theme
        Pin: release *
        Pin-Priority: -1


horizon-allowed:
  file.replace:
    - name: /etc/openstack-dashboard/local_settings.py
    - pattern: '#ALLOWED_HOSTS'
    - repl: 'ALLOWED_HOSTS'

horizon-hosts:
  file.replace:
    - name: /etc/openstack-dashboard/local_settings.py
    - pattern: 'horizon.example.com'
    - repl: 'localhost'

horizon-oshosts:
  file.replace:
    - name: /etc/openstack-dashboard/local_settings.py
    - pattern: 'OPENSTACK_HOST = ".*"'
    - repl: 'OPENSTACK_HOST = "{{ hostname }}"'

a2enmod-enable:
  cmd.run:
    - name: a2enmod wsgi
    - unless: 'test -e /etc/apache2/mods-enabled/wsgi.load'

horizon-restart:
  cmd.run:
    - order: last
    - onchanges:
      - cmd: a2enmod-enable
      - file: horizon-oshosts
      - file: horizon-hosts
      - file: horizon-allowed
      - file: uwm port replace
      - file: openstack-dash
      - pkg: horizon-pkgs
    - name: |
        service apache2 restart
        service memcached restart
{% endif %}


uwm port replace:
  file.replace:
    - order: last
    - name: /var/www/html/index.html
    - pattern: :\d{2,}"
    - repl: :{{ uwmport }}"
    - unless: grep {{ uwmport }} /var/www/html/index.html
