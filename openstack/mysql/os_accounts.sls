{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set dummy_int = salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', False )) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

include:
  - openstack.mysql.install

{% set accounts = ['keystone', 'nova', 'glance', 'cinder', 'neutron', 'quantum', 'dash', 'heat' ] %}
{% for user in accounts %}
{{ user }}-mysql:
  mysql_user.present:
    - name: {{ user }}
    - host: 'localhost'
    - password: {{ mypassword }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
  mysql_database:
    - present
    - name: {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
  mysql_grants.present:
    - grant: all privileges
    - database: "{{ user }}.*"
    - user: {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
      - mysql_database: {{ user }}-mysql

{{ user }}-mysql-nonlocal:
  mysql_user.present:
    - name: {{ user }}
    - host: {{ controllerip }}
    - password: {{ mypassword }}

{{ user }}-grant-wildcard:
  cmd.run:
    - name: mysql --user=root --password={{ mypassword }} -e "GRANT ALL ON {{ user }}.* TO '{{ user }}'@'%' IDENTIFIED BY '{{ mypassword }}';"
    - unless: mysql --user=root --password={{ mypassword }} -e "select Host,User from user Where user='{{ user }}' AND  host='%';" | grep {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
    - watch:
      - cmd: {{ user }}-grant-star
      - cmd: {{ user }}-grant-localhost

{{ user }}-grant-localhost:
  cmd.run:
    - name: mysql --user=root --password={{ mypassword }} -e "GRANT ALL ON {{ user }}.* TO '{{ user }}'@'%' IDENTIFIED BY '{{ mypassword }}';"
    - unless: mysql --user=root --password={{ mypassword }} -e "select Host,User from user Where user='{{ user }}' AND  host='%';" | grep {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
    - watch:
      - cmd: {{ user }}-grant-star

{{ user }}-grant-star:
  cmd.run:
    - name: mysql --user=root --password={{ mypassword }} -e "GRANT ALL ON {{ user }}.* TO '{{ user }}'@'*' IDENTIFIED BY '{{ mypassword }}';"
    - unless: mysql --user=root --password={{ mypassword }} -e "select Host,User from user Where user='{{ user }}' AND  host='*';" | grep {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
    - watch:
      - mysql_database: {{ user }}

{% endfor %}
