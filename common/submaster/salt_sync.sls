first attempt:
  git.latest:
    - name: https://github.com/Snergster/virl-salt.git
    - depth: 1
    - target: /srv/salt

just in case:
  git.latest:
    - target: /srv/salt
    - name: https://github.com/Snergster/virl-salt.git
    - depth: 1
    - force_clone: True
    - onfail:
      - git: first attempt
