virl-keys:
  git.latest:
    - name: {{salt['pillar.get']('master_git:keys_repo')}}
    - target: /etc/salt/pki/master/minions
    - identity: /root/.ssh/id_rsa
    - branch: master