{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}

rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server

rabbit_pass:
  cmd.run:
    - name: rabbitmqctl change_password guest {{ ospassword }}
    - user: root
    - require:
      - pkg: rabbitmq-server
