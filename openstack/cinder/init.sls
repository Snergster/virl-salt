{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set cinder_enabled = salt['pillar.get']('virl:cinder_enabled', salt['grains.get']('cinder_enabled', False)) %}
{% set cinder_file = salt['pillar.get']('virl:cinder_file', salt['grains.get']('cinder_file', False)) %}
{% set cinder_size = salt['pillar.get']('virl:cinder_size', salt['grains.get']('cinder_size', '2000')) %}
{% set cinder_location = salt['pillar.get']('virl:cinder_location', salt['grains.get']('cinder_location', '/var/lib/cinder/cinder-volumes.lvm')) %}
{% set enable_cinder = salt['pillar.get']('virl:enable_cinder', salt['grains.get']('enable_cinder', True)) %}
{% set rabbitpassword = salt['pillar.get']('virl:rabbitpassword', salt['grains.get']('password', 'password')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

cinder-pkgs:
  pkg.installed:
    - refresh: False
    - names:
      - cinder-api
      - cinder-scheduler
      - lvm2
      - cinder-volume



/etc/cinder/cinder.conf:
  file.managed:
    - file_mode: 755
    - template: jinja
    {% if masterless %}
    - source: "file:///srv/salt/openstack/cinder/files/cinder.conf"
    {% else %}
    - source: "salt://openstack/cinder/files/cinder.conf"
    {% endif %}

/etc/cinder/lvm.conf:
  file.managed:
    - file_mode: 755
    {% if masterless %}
    - source: "file:///srv/salt/openstack/cinder/files/lvm.conf"
    {% else %}
    - source: "salt://openstack/cinder/files/lvm.conf"
    {% endif %}

/etc/cinder/api-paste.ini:
  file.managed:
    - file_mode: 755
    - template: jinja
    {% if masterless %}
    - source: "file:///srv/salt/openstack/cinder/files/api-paste.ini"
    {% else %}
    - source: "salt://openstack/cinder/files/api-paste.ini"
    {% endif %}

{% if cinder_enabled %}
cinder-rclocal:
  file.replace:
    - name: /etc/rc.local
    - pattern: '# By default this script does nothing.'
    - repl: /sbin/losetup -f {{ cinder_location }}

{% endif %}

cinder-restart:
  cmd.run:
    - require:
      - file: /etc/cinder/cinder.conf
    - name: |
        cinder-manage db sync
        service cinder-volume restart
        service cinder-api restart
        service tgt restart
