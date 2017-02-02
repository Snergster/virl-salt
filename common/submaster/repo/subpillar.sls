virl-subpillar:
  git.latest:
    - name: {{salt['pillar.get']('master_git:subpillar_repo')}}
    - target: /srv/subpillar
    - https_user: {{salt['pillar.get']('master_git:subpillar_user')}}
    - https_pass: {{salt['pillar.get']('master_git:subpillar_pass')}}
    - branch: master
    - force_clone: True