{% set novapassword = salt['grains.get']('password', 'password') %}
{% set heatpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set mypassword = salt['grains.get']('mysql_password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set ks_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set serstart = salt['grains.get']('start_of_serial_port_range', '17000') %}
{% set serend = salt['grains.get']('end_of_serial_port_range', '18000') %}

heat-pkgs:
  pkg.installed:
    - order: 1
    - refresh: false
    - names:
      - heat-api
      - heat-api-cfn
      - heat-engine

/etc/heat:
  file.directory:
    - dir_mode: 755

heat-conn:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: '#connection = <None>'
    - repl: 'connection = mysql://heat:{{ mypassword }}@127.0.0.1/heat'

heat-rabbitpass:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: 'rabbit_password = RABBIT_PASS'
    - repl: 'rabbit_password = {{ ospassword }}'


heat-hostname:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: 'controller'
    - repl: '{{ hostname }}'

heat-publicip:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: 'PUBLICIP'
    - repl: '{{ public_ip }}'

heat-verbose:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: 'verbose=True'
    - repl: 'verbose=False'

heat-password:
  file.replace:
    - name: /etc/heat/heat.conf
    - pattern: 'HEAT_PASS'
    - repl: '{{ heatpassword }}'

/var/lib/heat/heat.sqlite:
  file.absent:
    - name: /var/lib/heat/heat.sqlite

heat-restart:
  cmd.run:
    - name: |
        heat-manage db_sync
        service heat-api restart
        service heat-api-cfn restart
        service heat-engine restart



