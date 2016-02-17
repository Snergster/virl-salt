
/home/virl/.ssh permission check:
  file.directory:
    - name: /home/virl/.ssh
    - makedirs: true
    - user: virl
    - group: virl
    - dir_mode: 0755

copy root to virl authorized:
  file.copy:
    - source: /root/.ssh/authorized_keys
    - name: /home/virl/.ssh/authorized_keys
    - makedirs: True
    - mode: 0755
    - force: True
    - user: virl
    - group: virl
