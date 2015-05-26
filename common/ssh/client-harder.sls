ssh client config:
  file.managed:
    - name: /etc/ssh/ssh_config
    - source: "salt://common/salt-master/files/ssh_config"
    - mode: 0644
