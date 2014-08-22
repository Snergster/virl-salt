{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set metapassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set neutid = salt['grains.get']('neutron_guestid', ' ') %}
{% set int_ip = salt['grains.get']('internalnet ip', '172.16.10.250' ) %}

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
    - user: virl
    - group: virl
    - dir_mode: 700
    - mode: 755
    - source: "salt://virl/files/xstartup"

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
    - source: "salt://virl/files/install_scripts/tightvnc.init"

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
    - source: "salt://virl/files/install_scripts/vnc.passwd"


tight-restart:
  cmd.run: 
    - order: last
    - name: |
        service tightvnc restart

