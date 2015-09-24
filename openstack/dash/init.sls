{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set enable_horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', True)) %}
{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}

include:
  - virl.web
  
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

{% if not kilo %}
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

{% endif %}
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
      - pkg: horizon-pkgs
      {% if not kilo %}
      - file: openstack-dash
      {% endif %}
    - name: |
        service apache2 restart
        service memcached restart
{% endif %}
