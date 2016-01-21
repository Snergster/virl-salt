/usr/local/bin/noprompt-ssh-keygen:
  file.managed:
    - source: salt://common/files/noprompt-ssh-keygen
    - mode: 0755

create key for virl:
  cmd.run:
    - user: virl
    - group: virl
    - name: /usr/local/bin/noprompt-ssh-keygen
    - require:
      - file: /usr/local/bin/noprompt-ssh-keygen
    - onlyif: test ! -e ~virl/.ssh/id_rsa.pub

point std at key:
  cmd.run:
    - name: crudini --set /etc/virl/common.cfg cluster ssh_key '~virl/.ssh/id_rsa'
