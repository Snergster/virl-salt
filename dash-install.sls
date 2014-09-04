{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set horizon = salt['grains.get']('enable horizon', 'False') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set uwmport = salt['grains.get']('virl user management', '19400') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}

{% if horizon == True %}

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
    - pattern: 'OPENSTACK_HOST = "127.0.0.1"'
    - repl: 'OPENSTACK_HOST = "{{ hostname }}"'

a2enmod-enable:
  cmd.run:
    - name: a2enmod wsgi

horizon-restart:
  cmd.run:
    - order: last
    - name: |
        service apache2 restart
        service memcached restart
{% endif %}

virl index:
  file.managed:
    - name: /var/www/index.html
    - mode: 0755
    - source: salt://files/install_scripts/index.html

uwm port replace:
  file.replace:
    - name: /var/www/index.html
    - pattern: 'UWMPORT'
    - repl: 'location.host + ":{{ uwmport }}"'
    - require:
      - file: virl index

#    - pattern: 'location.host + ":UWMPORT"'