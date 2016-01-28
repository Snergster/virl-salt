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
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', true)) %}

cinder-pkgs:
  pkg.installed:
    - refresh: False
    - names:
      - cinder-api
      - cinder-scheduler
      - lvm2
      - cinder-volume
{% if not kilo %}

oslo cinder prereq:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - onchanges:
      - pkg: cinder-pkgs
    - names:
      - oslo.messaging == 1.6.0
      - oslo.config == 1.6.0
      - pbr == 0.10.8


cinder-reinstall:
  pkg.installed:
    - refresh: False
    - names:
      - cinder-api
      - cinder-scheduler
      - lvm2
      - cinder-volume
    - onchanges:
      - pip: oslo cinder prereq
{% endif %}

/etc/cinder/cinder.conf:
  file.managed:
    - mode: 755
    - template: jinja
    {% if masterless %}
    - source: "file:///srv/salt/openstack/cinder/files/cinder.conf"
    {% else %}
    - source: "salt://openstack/cinder/files/cinder.conf"
    - source_hash: md5=915cc27d420bbf1eafc7e1443148e733
    {% endif %}

/etc/cinder/lvm.conf:
  file.managed:
    - mode: 755
    {% if masterless %}
    - source: "file:///srv/salt/openstack/cinder/files/lvm.conf"
    - source_hash: md5=230a9d0e4a697897a9d87cd1c6a3e2c5
    {% else %}
    - source: "salt://openstack/cinder/files/lvm.conf"

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

cinder backup:
  cmd.run:
    - onfail:
      - cmd: cinder-restart
    - name: |
        cinder-manage db sync
        service cinder-volume restart
        service cinder-api restart
        service tgt restart

