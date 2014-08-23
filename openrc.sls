{% set ADMIN_PASS = salt['grains.get']('password', 'password') %}
{% set controllername = salt['grains.get']('hostname', 'localhost') %}
{% set token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set ifhorizon = salt['grains.get']('enable horizon', 'False') %}
{% set uwmport = salt['grains.get']('virl user management', '19400') %}

/usr/local/bin/virl-openrc.sh:
  file.managed:
    - order: 1
    - source: salt://files/virl-openrc.sh
    - mode: 755

/home/virl/.bashrc:
  file.managed:
    - order: 1
    - source: salt://files/bashrc
    - user: virl
    - group: virl
    - mode: 755

/home/virl/.bash_profile:
  file.managed:
    - order: 1
    - source: salt://files/bash_profile
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/update-images:
  file.managed:
    - order: 1
    - source: salt://files/update_images
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images:
  file.managed:
    - order: 1
    - source: salt://files/add-images
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images-auto:
  file.managed:
    - order: 1
    - source: salt://files/add-images-auto
    - user: virl
    - group: virl
    - mode: 755

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

/usr/local/bin/add-servers:
  file.managed:
    - order: 1
    - source: salt://files/add-servers
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/adduser_openstack:
  file.managed:
    - order: 1
    - source: salt://files/adduser_openstack
    - user: virl
    - group: virl
    - mode: 755

adminpass:
  file.sed:
    - name: /usr/local/bin/virl-openrc.sh
    - before: 'export OS_PASSWORD=ADMIN_PASS'
    - after:  'export OS_PASSWORD={{ ADMIN_PASS }}'

adminpass2:
  file.sed:
    - name: /home/virl/.bashrc
    - before: 'export OS_PASSWORD=ADMIN_PASS'
    - after:  'export OS_PASSWORD={{ ADMIN_PASS }}'

controllername:
  file.sed:
    - name: /usr/local/bin/virl-openrc.sh
    - before: 'controller'
    - after:  '{{ controllername }}'

controllername2:
  file.sed:
    - name: /home/virl/.bashrc
    - before: 'controller'
    - after:  '{{ controllername }}'

token:
  file.replace:
    - name: /usr/local/bin/virl-openrc.sh
    - pattern: OS_TOKEN
    - repl: {{ token }}

token2:
  file.replace:
    - name: /home/virl/.bashrc
    - pattern: OS_TOKEN
    - repl: {{ token }}

{% if ifhorizon == 'False' %}

/var/www/index.html:
  file.managed:
    - order: 7
    - source: salt://files/install_scripts/index.html
    - mode: 755

uwmport replace:
  file.replace:
    - order: 8
    - name: /var/www/index.html
    - pattern: UWMPORT
    - repl: {{ uwmport }}

{% endif %}