{% set cinderpassword = salt['grains.get']('password', 'password') %}
{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set mypassword = salt['grains.get']('mysql_password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set cinder_file = salt['grains.get']('cinder_file', 'True') %}
{% set cinder_loc = salt['grains.get']('cinder_loc', '/var/lib/cinder/cinder-volumes.lvm') %}
{% set ks_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set cinder_enabled = salt['grains.get']('cinder_enabled', False) %}

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
        /sbin/losetup -f {{ cinder_loc }}
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
        service tgt restart
