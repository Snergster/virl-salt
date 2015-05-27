{% set consul_server = salt['pillar.get']('consul:consul_server', salt['grains.get']('consul_server', False)) %}
{% set consul_encrypt = salt['pillar.get']('consul:encrypt', salt['grains.get']('consul_encrypt', 'CGqVm/CjnR2+SRKU43roIA==')) %}
{% set consul_dc = salt['pillar.get']('consul:dc', salt['grains.get']('consul_dc', 'sjc')) %}
{% set publicport = salt['pillar.get']('virl:public_port', salt['grains.get']('public_port', 'eth0')) %}
{% set consul_server_ip = salt['pillar.get']('consul:consul_server_ip', salt['grains.get']('consul_server_ip', '"127.0.0.1"')) %}
{# consul_server_ip format '"127.0.0.1"','"10.10.10.10"'   #}
{% set node_name = salt['pillar.get']('consul:node_name', salt['grains.get']('id', 'replaceme')) %}


include:
  - .install

consul server init:
  file.managed:
    - name: /etc/init/consul.conf
    - source: salt://common/consul/files/server_consul.conf

/etc/consul.d/bootstrap/config.json:
  file.managed:
    - user: consul
    - group: consul
    - contents: '{"bootstrap": true, "server": true, "datacenter": "{{consul_dc}}", "verify_incoming": true, "verify_outgoing": true, "ca_file": "/etc/consul.d/ssl/ca.cert", "cert_file": "/etc/consul.d/ssl/consul.cert", "key_file": "/etc/consul.d/ssl/consul.key", "node_name": "{{node_name}}", "data_dir": "/var/consul", "encrypt": "{{consul_encrypt}}", "log_level": "INFO", "enable_syslog": true }'

/etc/consul.d/server/config.json:
  file.managed:
    - user: consul
    - group: consul
    - contents: '{"bootstrap": false, "server": true, "datacenter": "{{consul_dc}}", "verify_incoming": true, "verify_outgoing": true, "ca_file": "/etc/consul.d/ssl/ca.cert", "cert_file": "/etc/consul.d/ssl/consul.cert", "key_file": "/etc/consul.d/ssl/consul.key","node_name": "{{node_name}}", "data_dir": "/var/consul", "encrypt": "{{consul_encrypt}}", "log_level": "INFO", "enable_syslog": true, "start_join": [{{consul_server_ip}}] }'
