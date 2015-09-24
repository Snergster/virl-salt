{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set enable_horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', True)) %}
{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}

include:
  - openstack.mysql.open
  - virl.scripts

/usr/local/bin/virl-openrc.sh:
  file.managed:
    - order: 1
    - source: salt://virl/files/virl-openrc.sh
    - mode: 755

/home/virl/.bashrc:
  file.managed:
    - order: 1
    {% if kilo %}
    - source: salt://virl/files/kilo.bashrc
    {% else %}
    - source: salt://virl/files/bashrc
    {% endif %}
    - user: virl
    - group: virl
    - mode: 755

/home/virl/.bash_profile:
  file.managed:
    - order: 1
    - source: salt://virl/files/bash_profile
    - user: virl
    - group: virl
    - mode: 755

{% if enable_horizon == 'False' %}

/var/www/index.html:
  file.managed:
    - order: 7
    - source: salt://files/install_scripts/index.html
    - mode: 755

uwmport replace:
  file.replace:
    - order: 8
    - require:
      - file: /var/www/index.html
    - name: /var/www/index.html
    - pattern: :\d{2,}"
    - repl: :{{ uwmport }}"

{% endif %}

adminpass:
  file.replace:
    - name: /usr/local/bin/virl-openrc.sh
    - pattern: export OS_PASSWORD=.*
    - repl:  export OS_PASSWORD={{ ospassword }}

adminpass2:
  file.replace:
    - name: /home/virl/.bashrc
    - pattern: export OS_PASSWORD=.*
    - repl:  export OS_PASSWORD={{ ospassword }}

{% if kilo %}
controllername2v3:
  cmd.run:
    - name: salt-call --local file.replace /home/virl/.bashrc pattern='http:\/\/.*:35357\/v3' repl='http://{{ hostname }}:35357/v2.0'
    - unless: grep {{ hostname }}:35357 /home/virl/.bashrc


controllernamev3:
  cmd.run:
    - name: salt-call --local file.replace /usr/local/bin/virl-openrc.sh pattern='http:\/\/.*:35357\/v3' repl='http://{{ hostname }}:35357/v2.0'
    - unless: grep {{ hostname }}:35357 /usr/local/bin/virl-openrc.sh
{% endif %}
controllername2:
  cmd.run:
    - name: salt-call --local file.replace /home/virl/.bashrc pattern='http:\/\/.*:35357\/v2.0' repl='http://{{ hostname }}:35357/v2.0'
    - unless: grep {{ hostname }}:35357 /home/virl/.bashrc


controllername:
  cmd.run:
    - name: salt-call --local file.replace /usr/local/bin/virl-openrc.sh pattern='http:\/\/.*:35357\/v2.0' repl='http://{{ hostname }}:35357/v2.0'
    - unless: grep {{ hostname }}:35357 /usr/local/bin/virl-openrc.sh

token:
  file.replace:
    - name: /usr/local/bin/virl-openrc.sh
    - pattern: OS_TOKEN
    - repl: {{ ks_token }}

token2:
  file.replace:
    - name: /home/virl/.bashrc
    - pattern: OS_SERVICE_TOKEN=.*
    - repl: OS_SERVICE_TOKEN={{ ks_token }}
