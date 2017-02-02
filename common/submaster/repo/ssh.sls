/root/.ssh/id_rsa:
  file.managed:
    - makedirs: True
    - contents_pillar: master_git:virl_keys_private

/root/.ssh/id_rsa.pub:
  file.managed:
    - contents_pillar: master_git:virl_keys_public
    - require:
      - file: /root/.ssh/id_rsa