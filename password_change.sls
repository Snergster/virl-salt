{% set mypassword = salt['grains.get']('mysql_password', 'password') %}

{% set accounts = ['root','keystone', 'nova', 'glance', 'cinder', 'neutron', 'quantum', 'dash', 'heat' ] %}
{% for user in accounts %}
{{ user }}-mysql:
  mysql_user.present:
    - name: {{ user }}
    - host: 'localhost'
    - password: {{ mypassword }}
  mysql_database:
    - present
    - name: {{ user }}
  mysql_grants.present:
    - grant: all privileges
    - database: "{{ user }}.*"
    - user: {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
      - mysql_database: {{ user }}-mysql
{% endfor %}
