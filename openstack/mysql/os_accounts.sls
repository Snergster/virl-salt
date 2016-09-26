{% from "virl.jinja" import virl with context %}

include:
  - openstack.mysql.install

{% if virl.mitaka %}
{% set accounts = ['keystone', 'nova', 'glance', 'cinder', 'neutron', 'quantum', 'dash', 'heat', 'nova_api' ] %}

restart mysql again for funsies:
  cmd.run:
    - name: 'service mysql restart'

{% else %}
{% set accounts = ['keystone', 'nova', 'glance', 'cinder', 'neutron', 'quantum', 'dash', 'heat' ] %}
{% endif %}
{% for user in accounts %}

{% if virl.mitaka %}

{{ user }}-mysql virl:
  mysql_user.present:
    - password_column: authentication_string
    - name: {{ user }}
    - host: {{ virl.hostname }}
    - password: {{ virl.mypassword }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf

{{ user }}-mysql controllerip:
  mysql_user.present:
    - password_column: authentication_string
    - name: {{ user }}
    - host: {{ virl.controller_ip }}
    - password: {{ virl.mypassword }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf

{% endif %}

{{ user }}-mysql:
  mysql_user.present:
{% if virl.mitaka %}
    - password_column: authentication_string
{% endif %}
    - name: {{ user }}
    - host: 'localhost'
    - password: {{ virl.mypassword }}
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
{% if virl.mitaka %}
    - password_column: authentication_string
{% endif %}
    - name: {{ user }}
    - host: {{ virl.controller_ip }}
    - password: {{ virl.mypassword }}

{{ user }}-grant-wildcard:
  cmd.run:
    - name: mysql --user=root --password={{ virl.mypassword }} -e "GRANT ALL ON {{ user }}.* TO '{{ user }}'@'%' IDENTIFIED BY '{{ virl.mypassword }}';"
    - unless: mysql --user=root --password={{ virl.mypassword }} -e "select Host,User from user Where user='{{ user }}' AND  host='%';" | grep {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
    - watch:
      - cmd: {{ user }}-grant-star
      - cmd: {{ user }}-grant-localhost

{{ user }}-grant-localhost:
  cmd.run:
    - name: mysql --user=root --password={{ virl.mypassword }} -e "GRANT ALL ON {{ user }}.* TO '{{ user }}'@'%' IDENTIFIED BY '{{ virl.mypassword }}';"
    - unless: mysql --user=root --password={{ virl.mypassword }} -e "select Host,User from user Where user='{{ user }}' AND  host='%';" | grep {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
    - watch:
      - cmd: {{ user }}-grant-star

{{ user }}-grant-star:
  cmd.run:
    - name: mysql --user=root --password={{ virl.mypassword }} -e "GRANT ALL ON {{ user }}.* TO '{{ user }}'@'*' IDENTIFIED BY '{{ virl.mypassword }}';"
    - unless: mysql --user=root --password={{ virl.mypassword }} -e "select Host,User from user Where user='{{ user }}' AND  host='*';" | grep {{ user }}
    - require:
      - pkg: mysql-server
      - file: /etc/mysql/my.cnf
    - watch:
      - mysql_database: {{ user }}

{% endfor %}
