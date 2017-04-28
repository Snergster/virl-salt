{% from "virl.jinja" import virl with context %}

{% set accounts = ['root','keystone', 'nova', 'glance', 'cinder', 'neutron', 'quantum', 'dash', 'heat' ] %}

debconf-change:
  file.managed:
    - name: /tmp/debconf-change
    - unless: mysql -u root -p{{ virl.mypassword }} -e 'quit'
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

debconf-change-replace:
  file.replace:
    - name: /tmp/debconf-change
    - pattern: 'MYPASS'
    - repl: {{ virl.mypassword }}
    - onchanges:
      - file: debconf-change

debconf-change-set:
  cmd.run:
    - onchanges:
      - file: debconf-change-replace
    - name: |
        debconf-set-selections /tmp/debconf-change
        rm /tmp/debconf-change

debconf-change-noninteractive:
  cmd.run:
{% if virl.mitaka %}
    - name: dpkg-reconfigure -f noninteractive mysql-server-5.7
{% else %}
    - name: dpkg-reconfigure -f noninteractive mysql-server-5.5
{% endif %}
    - onchanges:
      - cmd: debconf-change-set

{% for user in accounts %}
{{ user }}-mysql:
  mysql_user.present:
{% if virl.mitaka %}
    - password_column: authentication_string
{% endif %}
    - name: {{ user }}
    - host: 'localhost'
    - password: {{ virl.mypassword }}
  mysql_database:
    - present
    - name: {{ user }}
  mysql_grants.present:
    - grant: all privileges
    - database: "{{ user }}.*"
    - user: {{ user }}

{{ user }}-mysql-nonlocal:
  mysql_user.present:
{% if virl.mitaka %}
    - password_column: authentication_string
{% endif %}
    - name: {{ user }}
    - host: {{ virl.int_ip }}
    - password: {{ virl.mypassword }}
{% endfor %}
