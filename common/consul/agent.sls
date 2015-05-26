{% set consul_server = salt['pillar.get']('consul:consul_server', salt['grains.get']('consul_server', False)) %}
{% set consul_encrypt = salt['pillar.get']('consul:encrypt', salt['grains.get']('consul_encrypt', 'CGqVm/CjnR2+SRKU43roIA==')) %}
{% set consul_dc = salt['pillar.get']('consul:dc', salt['grains.get']('consul_dc', 'sjc')) %}
{% set publicport = salt['pillar.get']('virl:public_port', salt['grains.get']('public_port', 'eth0')) %}
{% set consul_server_ip = salt['pillar.get']('consul:consul_server_ip', salt['grains.get']('consul_server_ip', '"127.0.0.1"')) %}
{% set node_name = salt['pillar.get']('consul:node_name', salt['grains.get']('id', 'replaceme')) %}

{# consul_server_ip format '"127.0.0.1"','"10.10.10.10"'   #}

include:
  - .install

consul agent init:
  file.managed:
    - name: /etc/init/consul.conf
    - source: salt://common/consul/files/agent_consul.conf

/etc/consul.d/client/config.json:
  file.managed:
    - contents: '{"server": false, "datacenter": "{{consul_dc}}", "node_name": "{{node_name}}", "ui_dir": "/home/consul/dist", "data_dir": "/var/consul", "encrypt": "{{consul_encrypt}}", "log_level": "INFO", "enable_syslog": true, "start_join": ["{{consul_server_ip}}"] }'
