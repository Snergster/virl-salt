{% set mypassword = salt['grains.get']('mysql_password', 'password') %}

# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
# Copyright 2013 Yazz D. Atlas <yazz.atlas@hp.com>
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
/tmp/debconf:
  file.managed:
    - order: 1
    - source: salt://files/debconf

debconf-replace:
  file.replace:
    - order: 2
    - name: /tmp/debconf
    - pattern: 'MYPASS'
    - repl: {{ mypassword }}

debconf-run:
  cmd.run:
    - order: 3
    - name: debconf-set-selections /tmp/debconf


mysql-client-5.5:
  pkg.installed

mysql-server-5.5:
  pkg.installed

python-mysqldb:
  pkg.installed

mysql:
  pkg:
    - installed
    - name: mysql-server
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: salt://files/my.cnf
    - require:
      - pkg: mysql-server
  service:
    - running
    - restart: True
    - enable: True
    - require:
      - pkg: mysql-server
    - watch:
      - file: /etc/mysql/my.cnf

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
    - watch:
      - service: mysql
  mysql_database:
    - present
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
      - mysql_database: {{ user }}
    - watch:
      - service: mysql

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
