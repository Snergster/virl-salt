{% set mypassword = salt['grains.get']('mysql_password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}

rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server

rabbit_pass:
  cmd.run:
    - name: rabbitmqctl change_password guest {{ ospassword }}
    - user: root
    - require:
      - pkg: rabbitmq-server

