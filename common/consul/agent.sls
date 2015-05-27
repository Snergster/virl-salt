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
    - user: consul
    - group: consul
    - contents: '{"server": false, "datacenter": "{{consul_dc}}", "advertise_addr": "{{ip}}", "bind_addr": "{{ip}}", "node_name": "{{node_name}}", "verify_incoming": true, "verify_outgoing": true, "ca_file": "/etc/consul.d/ssl/ca.cert", "cert_file": "/etc/consul.d/ssl/consul.cert", "key_file": "/etc/consul.d/ssl/consul.key","ui_dir": "/home/consul/dist", "data_dir": "/var/consul", "encrypt": "{{consul_encrypt}}", "log_level": "INFO", "enable_syslog": true, "start_join": ["{{consul_server_ip}}"] }'

consul webui:
  file.managed:
    - name: /tmp/consulwebui.zip
    - source: https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip
    - source_hash: md5=eb98ba602bc7e177333eb2e520881f4f
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
