{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

keystone-pkgs:
  pkg.installed:
    - names:
      - keystone


/etc/keystone/keystone.conf:
  file.managed:
    {% if masterless %}
    - source: file:///srv/salt/openstack/keystone/files/keystone.conf
    {% else %}
    - source: "salt://files/keystone.conf.jinja"
    {% endif %}
    - template: jinja
    - require:
      - pkg: keystone-pkgs

keystone db-sync:
  cmd.run:
    - name: su -s /bin/sh -c "keystone-manage db_sync" keystone
    - onchanges:
      - file: /etc/keystone/keystone.conf
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
    - names:
      - 'service keystone restart'
      - 'sleep 15'
