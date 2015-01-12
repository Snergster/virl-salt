{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set enable_horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', True)) %}
{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

include:
  - openstack.mysql.open

{% if not masterless %}
/usr/local/bin/virl-openrc.sh:
  file.managed:
    - order: 1
    - source: salt://virl/files/virl-openrc.sh
    - mode: 755

/home/virl/.bashrc:
  file.managed:
    - order: 1
    - source: salt://virl/files/bashrc
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

/usr/local/bin/update-images:
  file.managed:
    - order: 1
    - source: salt://virl/files/update_images
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images:
  file.managed:
    - order: 1
    - source: salt://virl/files/add-images
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images-auto:
  file.managed:
    - order: 1
    - source: salt://virl/files/add-images-auto
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-servers:
  file.managed:
    - order: 1
    - source: salt://virl/files/add-servers
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/adduser_openstack:
  file.managed:
    - order: 1
    - source: salt://virl/files/adduser_openstack
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
{% else %}

/usr/local/bin/virl-openrc.sh:
  file.copy:
    - order: 1
    - source: /srv/salt/virl/files/virl-openrc.sh
    - onlyif: 'test -e /srv/salt/virl/files/virl-openrc.sh'
    - force: true
    - mode: 755

/home/virl/.bashrc:
  file.copy:
    - order: 1
    - source: /srv/salt/virl/files/bashrc
    - onlyif: 'test -e /srv/salt/virl/files/bashrc'
    - force: true
    - user: virl
    - group: virl
    - mode: 755

/home/virl/.bash_profile:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/bash_profile
    - onlyif: 'test -e /srv/salt/virl/files/bash_profile'
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/update-images:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/update_images
    - onlyif: 'test -e /srv/salt/virl/files/update_images'
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/add-images
    - onlyif: 'test -e /srv/salt/virl/files/add-images'
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images-auto:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/add-images-auto
    - onlyif: 'test -e /srv/salt/virl/files/add-images-auto'
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-servers:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/add-servers
    - onlyif: 'test -e /srv/salt/virl/files/add-servers'
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/adduser_openstack:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/adduser_openstack
    - onlyif: 'test -e /srv/salt/virl/files/adduser_openstack'
    - user: virl
    - group: virl
    - mode: 755


{% endif %}

/opt/support/add-images:
  file.symlink:
    - target: /usr/local/bin/add-images
    - makedirs: true
    - mode: 0755

/opt/support/add-images-auto:
  file.symlink:
    - target: /usr/local/bin/add-images-auto
    - makedirs: true
    - mode: 0755

/opt/support/add-servers:
  file.symlink:
    - target: /usr/local/bin/add-servers
    - makedirs: true
    - mode: 0755

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


controllername2:
  cmd.run:
    - name: salt-call file.replace /home/virl/.bashrc pattern='http:\/\/.*:35357\/v2.0' repl='http://{{ hostname }}:35357/v2.0'
    - unless: grep {{ hostname }}:35357 /home/virl/.bashrc


controllername:
  cmd.run:
    - name: salt-call file.replace /usr/local/bin/virl-openrc.sh pattern='http:\/\/.*:35357\/v2.0' repl='http://{{ hostname }}:35357/v2.0'
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
