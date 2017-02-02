virl-salt:
  git.latest:
    - name: {{salt['pillar.get']('master_git:salt_repo')}}
    - target: /srv/salt
    - http_user: {{salt['pillar.get']('master_git:salt_user')}}
    - http_pass: {{salt['pillar.get']('master_git:salt_pass')}}
    - branch: master
    - force_clone: True