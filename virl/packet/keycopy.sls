
copy root to virl authorized:
  file.copy:
    - source: /root/.ssh/authorized_keys
    - name: /home/virl/.ssh/authorized_keys
    - makedirs: True
    - force: True
    - user: virl
    - group: virl
