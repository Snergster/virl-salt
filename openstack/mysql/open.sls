{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set dummy_int = salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', False )) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}


{% if dummy_int == True %}

mysql port anycast:
  file.replace:
    - name: /etc/mysql/my.cnf
    - pattern: ^bind-address.*
    - repl: 'bind-address = {{ controllerip }}'
    - onlyif: ls /etc/mysql/my.cnf
  cmd.wait:
    - name: 'service mysql restart'
    - watch:
      - file: mysql port anycast

{% else %}

mysql port anycast:
  file.replace:
    - name: /etc/mysql/my.cnf
    - pattern: ^bind-address.*
    - repl: 'bind-address = 0.0.0.0'
    - onlyif: ls /etc/mysql/my.cnf
  cmd.wait:
    - name: 'service mysql restart'
    - watch:
      - file: mysql port anycast
      
{% endif %}