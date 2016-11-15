{% from "virl.jinja" import virl with context %}

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
# 8/3/15  Note: This state has changed HEAVILY since yazz's original but im leaving the
# above to show proper inspiration credit

/tmp/debconf creation:
  file.managed:
    - name: /tmp/debconf
    - contents: |
        mysql-server mysql-server/root_password password MYPASS
        mysql-server mysql-server/root_password_again password MYPASS
{% if virl.mitaka %}
        mysql-server-5.7 mysql-server/root_password password MYPASS
        mysql-server-5.7 mysql-server/root_password_again password MYPASS
{% else %}
        mysql-server-5.5 mysql-server/root_password password MYPASS
        mysql-server-5.5 mysql-server/root_password_again password MYPASS
{% endif %}


debconf-replace:
  file.replace:
    - name: /tmp/debconf
    - pattern: 'MYPASS'
    - repl: {{ virl.mypassword }}
    - require:
      - file: /tmp/debconf creation

debconf-run:
  cmd.run:
    - require:
      - file: debconf-replace
    - name: |
        debconf-set-selections /tmp/debconf
        rm /tmp/debconf

{% if virl.mitaka %}
mysql-client-5.7:
  pkg.installed
mysql-server-5.7:
  pkg.installed
{% else %}
mysql-client-5.5:
  pkg.installed
mysql-server-5.5:
  pkg.installed
{% endif %}

python-mysqldb:
  pkg.installed

debconf-change:
  file.managed:
    - name: /tmp/debconf-change
    - unless: mysql -u root -p{{ virl.mypassword }} -e 'quit'
    - contents: |
        mysql-server mysql-server/root_password password {{ virl.mypassword }}
        mysql-server mysql-server/root_password_again password {{ virl.mypassword }}
{% if virl.mitaka %}
        mysql-server-5.7 mysql-server/root_password password {{ virl.mypassword }}
        mysql-server-5.7 mysql-server/root_password_again password {{ virl.mypassword }}
{% else %}
        mysql-server-5.5 mysql-server/root_password password {{ virl.mypassword }}
        mysql-server-5.5 mysql-server/root_password_again password {{ virl.mypassword }}
{% endif %}

debconf-change-set:
  cmd.run:
    - onchanges:
      - file: debconf-change
    - name: |
        debconf-set-selections /tmp/debconf-change
        rm /tmp/debconf-change

debconf-change-noninteractive:
  cmd.run:
{% if virl.mitaka %}
    - name: dpkg-reconfigure -f noninteractive mysql-server-5.7
{% else %}
    - name: dpkg-reconfigure -f noninteractive mysql-server-5.5
{% endif %}    - onchanges:
      - file: debconf-change


verify symlink:
  file.symlink:
    - name: /usr/local/bin/openstack-config
    - target: /usr/bin/crudini
    - mode: 0755

mysql:
  pkg:
    - installed
    - name: mysql-server

my.cnf template:
  file.managed:
    - name: /etc/mysql/my.cnf
{% if virl.mitaka %}
    - source: salt://openstack/mysql/files/mitaka.my.cnf
{% else %}
    - source: salt://openstack/mysql/files/my.cnf
{% endif %}
    - makedirs: True
  service:
    - running
    - name: mysql
    - restart: True
    - enable: True
    - watch:
      - file: /etc/mysql/my.cnf

{% if virl.mitaka %}

root-localhost-wildcard:
  mysql_user.present:
    - password_column: authentication_string
    - name: root
    - host: 'localhost'
    - password: {{ virl.mypassword }}

root-localhost-wildcard grants:
  mysql_grants.present:
    - grant: ALL PRIVILEGES
    - database: '*.*'
    - user: root
    - host: 'localhost'

root-virl-wildcard:
  mysql_user.present:
    - password_column: authentication_string
    - name: root
    - host: 'virl'
    - password: {{ virl.mypassword }}

root-virl-wildcard grants:
  mysql_grants.present:
    - grant: ALL PRIVILEGES
    - database: '*.*'
    - user: root
    - host: 'virl'

root-hostname-wildcard:
  mysql_user.present:
    - password_column: authentication_string
    - name: root
    - host: '{{virl.hostname}}'
    - password: {{ virl.mypassword }}

root-hostname-wildcard grants:
  mysql_grants.present:
    - grant: ALL PRIVILEGES
    - database: '*.*'
    - user: root
    - host: '{{virl.hostname}}'

root-ip-wildcard:
  mysql_user.present:
    - password_column: authentication_string
    - name: root
    - host: '{{virl.controller_ip}}'
    - password: {{ virl.mypassword }}

root-ip-wildcard grants:
  mysql_grants.present:
    - grant: ALL PRIVILEGES
    - database: '*.*'
    - user: root
    - host: '{{virl.controller_ip}}'

root-controller-wildcard:
  mysql_user.present:
    - password_column: authentication_string
    - name: root
    - host: 'controller'
    - password: {{ virl.mypassword }}

root-controller-wildcard grants:
  mysql_grants.present:
    - grant: ALL PRIVILEGES
    - database: '*.*'
    - user: root
    - host: 'controller'

root-rawip-wildcard:
  mysql_user.present:
    - password_column: authentication_string
    - name: root
    - host: '172.16.%.%'
    - password: {{ virl.mypassword }}

root-rawip-wildcard grants:
  mysql_grants.present:
    - grant: ALL PRIVILEGES
    - database: '*.*'
    - user: root
    - host: '172.16.%.%'

{% endif %}


{% if virl.dummy_int %}

mysql port for dummies:
  file.replace:
    - name: /etc/mysql/my.cnf
    - pattern: ^bind-address.*
    - repl: 'bind-address = {{ virl.controller_ip }}'
    - require:
      - pkg: mysql
  cmd.wait:
    - name: 'service mysql restart'
    - watch:
      - file: mysql port for dummies

{% else %}

mysql port anycast:
  file.replace:
    - name: /etc/mysql/my.cnf
    - pattern: ^bind-address.*
    - repl: 'bind-address = 0.0.0.0'
    - require:
      - pkg: mysql
  cmd.wait:
    - name: 'service mysql restart'
    - watch:
      - file: mysql port anycast

{% endif %}
