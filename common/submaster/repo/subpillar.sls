virl-subpillar:
  git.latest:
    - name: {{salt['pillar.get']('master_git:subpillar_repo')}}
    - target: /srv/subpillar
    - http_user: {{salt['pillar.get']('master_git:subpillar_user')}}
    - http_pass: {{salt['pillar.get']('master_git:subpillar_pass')}}
    - branch: master
    - force_clone: True