/home/virl/.ssh/authorized_keys:
  file.managed:
    - user: virl
    - group: virl
    - makedirs: true
    - contents_pillar: virl:virl_ssh_key

/root/.ssh/authorized_keys:
  file.managed:
    - user: root
    - group: root
    - makedirs: true
    - contents_pillar: virl:virl_ssh_key
