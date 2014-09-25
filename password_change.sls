{% set mypassword = salt['grains.get']('mysql_password', 'password') %}

{% set accounts = ['root','keystone', 'nova', 'glance', 'cinder', 'neutron', 'quantum', 'dash', 'heat' ] %}
{% for user in accounts %}
{{ user }}-mysql:
  mysql_user.present:
    - name: {{ user }}
    - host: 'localhost'
    - password: {{ mypassword }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
    - watch:
      - service: mysql
  mysql_database:
    - present
    - name: {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
    - watch:
      - service: mysql
  mysql_grants.present:
    - grant: all privileges
    - database: "{{ user }}.*"
    - user: {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
      - mysql_database: {{ user }}-mysql
    - watch:
      - service: mysql
