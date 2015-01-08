{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}

{% set accounts = ['root','keystone', 'nova', 'glance', 'cinder', 'neutron', 'quantum', 'dash', 'heat' ] %}

/tmp/debconf-change:
  file.managed:
    - unless: mysql -u root -p{{ mypassword }} -e 'quit'
    - contents: |
        mysql-server mysql-server/root_password password MYPASS
        mysql-server mysql-server/root_password_again password MYPASS
        mysql-server-5.5 mysql-server/root_password password MYPASS
        mysql-server-5.5 mysql-server/root_password_again password MYPASS

debconf-change-replace:
  file.replace:
    - order: 2
    - name: /tmp/debconf-change
    - pattern: 'MYPASS'
    - repl: {{ mypassword }}
    - onlyif: ls /tmp/debconf-change

debconf-change-set:
  cmd.run:
    - onchanges:
      - file: debconf-change-replace
    - name: |
        debconf-set-selections /tmp/debconf-change
        rm /tmp/debconf-change

debconf-change-noninteractive:
  cmd.run:
    - order: 4
    - name: dpkg-reconfigure -f noninteractive mysql-server-5.5
    - onchanges:
      - cmd: debconf-change-set

{% for user in accounts %}
{{ user }}-mysql:
  mysql_user.present:
    - onchanges:
      - cmd: debconf-change-noninteractive
    - order: 6
    - name: {{ user }}
    - host: 'localhost'
    - password: {{ mypassword }}
  mysql_database:
    - onchanges:
      - cmd: debconf-change-noninteractive
    - present
    - name: {{ user }}
  mysql_grants.present:
    - onchanges:
      - cmd: debconf-change-noninteractive
    - grant: all privileges
    - database: "{{ user }}.*"
    - user: {{ user }}
{% endfor %}
