/home/virl/.ssh/authorized_keys:
  file.managed:
    - owner: virl
    - group: virl
    - makedirs: true
    - contents_pillar: virl:virl_ssh_key
    - onlyif: test ! -e /home/virl/.ssh/authorized_keys
