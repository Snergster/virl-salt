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

rabbitmq restart:
  service:
    - name: rabbitmq-server
    - running
    - enable: True
    - watch:
      - cmd: rabbit_pass
      - file: /etc/rabbitmq/rabbitmq-env.conf

/etc/rabbitmq/rabbitmq-env.conf:
  file.managed:
    - require:
      - pkg: rabbitmq-server
    - makedirs: True
    - contents: |
        RABBITMQ_NODE_IP_ADDRESS=0.0.0.0



