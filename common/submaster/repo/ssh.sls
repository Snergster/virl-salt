/root/.ssh/id_rsa:
  file.managed:
    - makedirs: True
    - contents_pillar: master_git:keys_deploy_private

/root/.ssh/id_rsa.pub:
  file.managed:
    - contents_pillar: master_git:keys_deploy_public
    - require:
      - file: /root/.ssh/id_rsa