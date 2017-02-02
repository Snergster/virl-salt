virl-pillar:
  git.latest:
    - name: {{salt['pillar.get']('master_git:pillar_repo')}}
    - target: /srv/pillar
    - https_user: {{salt['pillar.get']('master_git:pillar_user')}}
    - https_pass: {{salt['pillar.get']('master_git:pillar_pass')}}
    - branch: master
    - force_clone: True