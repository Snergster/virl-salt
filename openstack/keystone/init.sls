{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
keystone-pkgs:
  pkg.installed:
    - order: 1
    - names:
      - keystone

keystone_token:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'DEFAULT'
    - parameter: 'admin_token'
    - value: '{{ ks_token }}'
    - require:
      - pkg: keystone-pkgs

/etc/keystone/keystone.conf:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'database'
    - parameter: 'connection'
    - value: ' mysql://keystone:{{ mypassword }}@{{ controllerip }}/keystone'
    - require:
      - pkg: keystone-pkgs

logdir:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: 'DEFAULT'
    - parameter: 'log_dir'
    - value: '/var/log/keystone'
    - require:
      - pkg: keystone-pkgs
      
keystone db-sync:
  cmd.run:
    - name: su -s /bin/sh -c "keystone-manage db_sync" keystone
    - require:
      - pkg: keystone-pkgs

/usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1:
  cron.present:
    - user: root
    - hour: 5
    - require:
      - cmd: keystone db-sync

key-db-sync:
  cmd.run:
    - order: last
    - name: service keystone restart
    - require:
      - cmd: keystone db-sync
