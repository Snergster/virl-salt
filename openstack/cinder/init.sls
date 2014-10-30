{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set cinder_enabled = salt['pillar.get']('virl:cinder_enabled', salt['grains.get']('cinder_enabled', False)) %}
{% set cinder_file = salt['pillar.get']('virl:cinder_file', salt['grains.get']('cinder_file', False)) %}
{% set cinder_size = salt['pillar.get']('virl:cinder_size', salt['grains.get']('cinder_size', '2000')) %}
{% set cinder_location = salt['pillar.get']('virl:cinder_location', salt['grains.get']('cinder_location', '/var/lib/cinder/cinder-volumes.lvm')) %}
{% set enable_cinder = salt['pillar.get']('virl:enable_cinder', salt['grains.get']('enable_cinder', True)) %}
{% set rabbitpassword = salt['pillar.get']('virl:rabbitpassword', salt['grains.get']('password', 'password')) %}

cinder-pkgs:
  pkg.installed:
    - order: 1
    - refresh: False
    - names:
      - cinder-api
      - cinder-scheduler
      - lvm2
      - cinder-volume



/etc/cinder/cinder.conf:
  file.managed:
    - file_mode: 755
    - source: "salt://files/cinder.conf"

cinder-conn:
  openstack_config.present:
    - filename: /etc/cinder/cinder.conf
    - section: 'database'
    - parameter: 'connection'
    - value: 'mysql://cinder:{{ mypassword }}@127.0.0.1/cinder'

cinder-rabbitpass:
  openstack_config.present:
    - filename: /etc/cinder/cinder.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_password'
    - value:  '{{ rabbitpassword }}'

cinder-adminpass:
  openstack_config.present:
    - filename: /etc/cinder/cinder.conf
    - section: 'keystone_authtoken'
    - parameter: 'admin_password'
    - value:  '{{ ospassword }}'

{% if cinder_enabled == True %}
cinder-rclocal:
  file.append:
    - name: /etc/rc.local
    - text: |
        /sbin/losetup -f {{ cinder_location }}
        exit 0

{% endif %}

cinder-rabbit-hostname:
  openstack_config.present:
    - filename: /etc/cinder/cinder.conf
    - section: 'DEFAULT'
    - parameter: 'rabbit_host'
    - value:  '{{ hostname }}'

cinder-auth-uri:
  openstack_config.present:
    - filename: /etc/cinder/cinder.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_uri'
    - value:  'http://{{ hostname }}:5000/v2.0'

cinder-auth-host:
  openstack_config.present:
    - filename: /etc/cinder/cinder.conf
    - section: 'keystone_authtoken'
    - parameter: 'auth_host'
    - value: '{{ hostname }}'

cinder-verbose:
  openstack_config.present:
    - filename: /etc/cinder/cinder.conf
    - section: 'DEFAULT'
    - parameter: 'verbose'
    - value:  'False'


cinder-restart:
  cmd.run:
    - name: |
        cinder-manage db sync
        service cinder-volume restart
        service cinder-api restart
        service tgt restart
