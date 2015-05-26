ssh server config:
  file.managed:
    - name: /etc/ssh/ssh_config
    - source: "salt://common/salt-master/files/sshd_config"
    - mode: 0644

salt://common/salt-master/files/moduli.sh:
  cmd.script:
    - user: root

