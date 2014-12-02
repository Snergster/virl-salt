{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}

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
      
