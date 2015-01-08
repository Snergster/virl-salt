{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set metapassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set neutid = salt['grains.get']('neutron_guestid', ' ') %}
{% set int_ip = salt['grains.get']('internalnet_ip', '172.16.10.250' ) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

tightvnc-pkgs:
  pkg.installed:
    - order: 1
    - refresh: False
    - names:
      - tightvncserver
      - blackbox

/home/virl/.vnc/xstartup:
  file.managed:
    - order: 2
    - makedirs: True
    - require:
      - file: /home/virl/.vnc
    - user: virl
    - group: virl
    - dir_mode: 700
    - mode: 755
    {% if masterless %}
    - source: "file:///srv/salt/common/tightvncserver/files/xstartup"
    {% else %}
    - source: "salt://files/xstartup"
    {% endif %}

/home/virl/.vnc:
    file.directory:
    - order: 3
    - user: virl
    - group: virl
    - dir_mode: 700

/etc/init.d/tightvnc:
  file.managed:
    - order: 2
    - mode: 755
    {% if masterless %}
    - source: "file:///srv/salt/common/tightvncserver/files/tightvnc.init"
    {% else %}
    - source: "salt://files/install_scripts/tightvnc.init"
    {% endif %}

/etc/rc2.d/S97tightvnc:
  file.symlink:
    - order: 3
    - target: /etc/init.d/tightvnc
    - mode: 0755

/home/virl/.vnc/passwd:
  file.managed:
    - order: 2
    - user: virl
    - group: virl
    - makedirs: True
    - dir_mode: 700
    - mode: 600
    {% if masterless %}
    - source: "file:///srv/salt/common/tightvncserver/files/vnc.passwd"
    {% else %}
    - source: "salt://files/install_scripts/vnc.passwd"
    {% endif %}


tight-restart:
  cmd.run:
    - order: last
    - name: |
        service tightvnc restart
