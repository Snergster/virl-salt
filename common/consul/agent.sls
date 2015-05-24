include:
  - .install

consul agent init:
  file.managed:
    - name: /etc/init/consul.conf
    - source: salt://common/consul/files/agent_consul.conf
