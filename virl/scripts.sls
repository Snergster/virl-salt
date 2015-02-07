{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set enable_horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', True)) %}
{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

{% if not masterless %}

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

{% else %}

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
