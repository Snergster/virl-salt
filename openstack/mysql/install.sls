{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set dummy_int = salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', False )) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

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
/tmp/debconf creation:
  file.managed:
    - name: /tmp/debconf
    - contents: |
        mysql-server mysql-server/root_password password MYPASS
        mysql-server mysql-server/root_password_again password MYPASS
        mysql-server-5.5 mysql-server/root_password password MYPASS
        mysql-server-5.5 mysql-server/root_password_again password MYPASS


debconf-replace:
  file.replace:
    - order: 2
    - name: /tmp/debconf
    - pattern: 'MYPASS'
    - repl: {{ mypassword }}
    - require:
      - file: /tmp/debconf creation

debconf-run:
  cmd.run:
    - require:
      - file: debconf-replace
    - name: |
        debconf-set-selections /tmp/debconf
        rm /tmp/debconf


mysql-client-5.5:
  pkg.installed

mysql-server-5.5:
  pkg.installed

python-mysqldb:
  pkg.installed

debconf-change:
  file.managed:
    - name: /tmp/debconf-change
    - unless: mysql -u root -p{{ mypassword }} -e 'quit'
    - contents: |
        mysql-server mysql-server/root_password password {{ mypassword }}
        mysql-server mysql-server/root_password_again password {{ mypassword }}
        mysql-server-5.5 mysql-server/root_password password {{ mypassword }}
        mysql-server-5.5 mysql-server/root_password_again password {{ mypassword }}

debconf-change-set:
  cmd.run:
    - onchanges:
      - file: debconf-change
    - name: |
        debconf-set-selections /tmp/debconf-change
        rm /tmp/debconf-change

debconf-change-noninteractive:
  cmd.run:
    - name: dpkg-reconfigure -f noninteractive mysql-server-5.5
    - onchanges:
      - cmd: debconf-change


verify symlink:
  file.symlink:
    - name: /usr/local/bin/openstack-config
    - target: /usr/bin/crudini
    - mode: 0755

mysql:
  pkg:
    - installed
    - name: mysql-server
  {% if masterless %}
  file.copy:
    - source: /srv/salt/openstack/mysql/files/my.cnf
    - force: true
  {% else %}
  file.managed:
    - source: salt://openstack/mysql/files/my.cnf
  {% endif %}
    - name: /etc/mysql/my.cnf
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

{% if dummy_int == True %}

mysql port for dummies:
  file.replace:
    - name: /etc/mysql/my.cnf
    - pattern: ^bind-address.*
    - repl: 'bind-address = {{ controllerip }}'
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
