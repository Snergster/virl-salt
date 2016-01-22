ssh server config:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: "salt://common/ssh/files/sshd_config"
    - mode: 0644

salt://common/salt-master/files/moduli.sh:
  cmd.script:
    - user: root

