/usr/local/bin/noprompt-ssh-keygen:
  file.managed:
    - source: salt://virl/files/noprompt-ssh-keygen
    - mode: 0755

create key for virl:
  cmd.run:
    - user: virl
    - group: virl
    - name: /usr/local/bin/noprompt-ssh-keygen
    - require:
      - file: /usr/local/bin/noprompt-ssh-keygen
    - onlyif: test ! -e ~virl/.ssh/id_rsa.pub
