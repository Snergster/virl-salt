{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}
{% set cluster = salt['pillar.get']('virl:virl_cluster', salt['grains.get']('virl_cluster', False )) %}
{% from "virl.jinja" import virl with context %}

rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server

kill-the-rabbit:
  service.dead:
    - name: rabbitmq-server

revive-the-rabbit:
  service.running:
    - name: rabbitmq-server
    - enable: True

poke-the-rabbit-after-changes:
  service:
    - name: rabbitmq-server
    - running
    - enable: True
    - watch:
      - cmd: rabbit_pass
      - file: /etc/rabbitmq/rabbitmq-env.conf
{% if cluster %}
      - file: /etc/rabbitmq/rabbitmq.config
{% endif %}

rabbit_pass:
  cmd.run:
    - name: rabbitmqctl change_password guest {{ ospassword }}
    - user: root
    - require:
      - pkg: rabbitmq-server

/etc/rabbitmq/rabbitmq-env.conf:
  file.managed:
    - require:
      - pkg: rabbitmq-server
    - makedirs: True
    - contents: |
        RABBITMQ_NODE_IP_ADDRESS=0.0.0.0

{% if cluster %}
/etc/rabbitmq/rabbitmq.config:
  file.managed:
    - require:
      - pkg: rabbitmq-server
    - makedirs: True
    - contents: |
        [{rabbit, [{loopback_users, []}]}].

{% endif %}




