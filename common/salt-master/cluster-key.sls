/usr/local/bin/noprompt-ssh-keygen:
  file.managed:
    - source: salt://common/files/noprompt-ssh-keygen
    - mode: 0755

create sshdir for virl:
  cmd.run:
    - user: virl
    - group: virl
    - name: mkdir -p ~/.ssh

create key for virl:
  cmd.run:
    - user: virl
    - group: virl
    - name: /usr/local/bin/noprompt-ssh-keygen
    - require:
      - file: /usr/local/bin/noprompt-ssh-keygen
      - cmd: create sshdir for virl
    - onlyif: test ! -e ~virl/.ssh/id_rsa.pub

point std at key:
  cmd.run:
    - name: crudini --set /etc/virl/common.cfg cluster ssh_key '~virl/.ssh/id_rsa'
    - onlyif: 
      - test -e ~virl/.ssh/id_rsa.pub
      - test -e /etc/virl/common.cfg

replicate ssh key to root:
  file.copy:
    - name: /root/.ssh/id_rsa
    - source: /home/virl/.ssh/id_rsa
    - makedirs: True
    - user: root
    - mode: 0600
    - force: True

replicate pub ssh key to root:
  file.copy:
    - name: /root/.ssh/id_rsa.pub
    - source: /home/virl/.ssh/id_rsa.pub
    - makedirs: True
    - user: root
    - mode: 0644
    - force: True

virl_ssh_key to grains:
  cmd.run:
    - name: /usr/local/bin/ssh_to_grain
    - require:
      - file: virl_ssh_key to grains
  file.managed:
    - name: /usr/local/bin/ssh_to_grain
    - mode: 0755
    - contents:  |
            #!/bin/bash
            value=`cat ~virl/.ssh/id_rsa.pub`
            salt-call --local grains.setval  virl_ssh_key "$value"
