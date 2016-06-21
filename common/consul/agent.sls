{% set consul_server = salt['pillar.get']('consul:consul_server', salt['grains.get']('consul_server', False)) %}
{% set consul_encrypt = salt['pillar.get']('consul:encrypt', salt['grains.get']('consul_encrypt', 'CGqVm/CjnR2+SRKU43roIA==')) %}
{% set consul_dc = salt['pillar.get']('consul:dc', salt['grains.get']('consul_dc', 'sjc')) %}
{% set publicport = salt['pillar.get']('virl:public_port', salt['grains.get']('public_port', 'eth0')) %}
{% set consul_server_ip = salt['pillar.get']('consul:consul_server_ip', salt['grains.get']('consul_server_ip', '"127.0.0.1"')) %}
{% set node_name = salt['pillar.get']('consul:node_name', salt['grains.get']('id', 'replaceme')) %}
{# consul_server_ip format '"127.0.0.1"','"10.10.10.10"'   #}
{% set ipaddr = salt['network.interface_ip'](salt['grains.get']('public_port', 'eth0'))%}
include:
  - .install

consul agent init:
  file.managed:
    - name: /etc/init/consul.conf
    - source: salt://common/consul/files/agent_consul.conf

/etc/consul.d/client/config.json:
  file.managed:
    - user: consul
    - group: consul
    - contents: '{"server": false, "datacenter": "{{consul_dc}}", "advertise_addr": "{{ipaddr}}", "disable_remote_exec": true, "bind_addr": "{{ipaddr}}", "node_name": "{{node_name}}", "verify_incoming": true, "verify_outgoing": true, "ca_file": "/etc/consul.d/ssl/ca.cert", "cert_file": "/etc/consul.d/ssl/consul.cert", "key_file": "/etc/consul.d/ssl/consul.key","ui_dir": "/home/consul/dist", "data_dir": "/var/consul", "encrypt": "{{consul_encrypt}}", "log_level": "INFO", "enable_syslog": true, "start_join": ["{{consul_server_ip}}"] }'

consul webui:
  file.managed:
    - name: /tmp/consulwebui.zip
    - source: https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_web_ui.zip
    - source_hash: sha256=73c5e7ee50bb4a2efe56331d330e6d7dbf46335599c028344ccc4031c0c32eb0
  module.run:
    - name: archive.unzip
    - zip_file: /tmp/consulwebui.zip
    - dest: /home/consul

web permissions:
  file.directory:
    - name: /home/consul/dist
    - require:
      - module: consul webui
    - user: consul
    - group: consul
    - recurse:
      - user
      - group
