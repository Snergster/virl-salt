{% set sshd_port = salt['pillar.get']('common:port:sshd', salt['grains.get']('sshd_port', '22')) %}

/etc/ssh/sshd_config:
  file.replace:
    - pattern: Port 22
    - repl: Port {{ sshd_port }}
