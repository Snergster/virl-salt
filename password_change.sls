{% set mypassword = salt['grains.get']('mysql_password', 'password') %}

{% set accounts = ['root','keystone', 'nova', 'glance', 'cinder', 'neutron', 'quantum', 'dash', 'heat' ] %}

/tmp/debconf-change:
  file.managed:
    - order: 1
    - source: salt://files/debconf

debconf-change-replace:
  file.replace:
    - order: 2
    - name: /tmp/debconf-change
    - pattern: 'MYPASS'
    - repl: {{ mypassword }}

debconf-change-set:
  cmd.run:
    - order: 3
    - name: debconf-set-selections /tmp/debconf-change

debconf-change-noninteractive:
  cmd.run:
    - order: 4
    - name: dpkg-reconfigure -f noninteractive mysql-server-5.5

debconf-change-run:
  cmd.run:
    - order: 5
    - name: dpkg-reconfigure mysql-server-5.5


{% for user in accounts %}
{{ user }}-mysql:
  mysql_user.present:
    - order: 6
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
{% endfor %}
