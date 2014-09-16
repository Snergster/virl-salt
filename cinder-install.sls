{% set cinderpassword = salt['grains.get']('password', 'password') %}
{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
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
  file.replace:
    - name: /etc/cinder/cinder.conf
    - pattern: '#connection = <None>'
    - repl: 'connection = mysql://cinder:{{ cinderpassword }}@127.0.0.1/cinder'

cinder-rabbitpass:
  file.replace:
    - name: /etc/cinder/cinder.conf
    - pattern: 'rabbit_password = RABBIT_PASS'
    - repl: 'rabbit_password = {{ rabbitpassword }}'

{% if cinder_enabled = True %}
cinder-rclocal:
  file.append:
    - name: /etc/rc.local
    - text: |
        /sbin/losetup -f {{ cinder_loc }}
        exit 0

{% endif %}

cinder-hostname:
  file.replace:
    - name: /etc/cinder/cinder.conf
    - pattern: 'controller'
    - repl: '{{ hostname }}'

cinder-publicip:
  file.replace:
    - name: /etc/cinder/cinder.conf
    - pattern: 'PUBLICIP'
    - repl: '{{ public_ip }}'

cinder-verbose:
  file.replace:
    - name: /etc/cinder/cinder.conf
    - pattern: 'verbose=True'
    - repl: 'verbose=False'

cinder-password:
  file.replace:
    - name: /etc/cinder/cinder.conf
    - pattern: 'CINDER_PASS'
    - repl: '{{ cinderpassword }}'


cinder-restart:
  cmd.run:
    - name: |
        cinder-manage db sync
        service cinder-volume restart
        service tgt restart


