first attempt:
  git.latest:
    - name: https://github.com/Snergster/virl-salt.git
    - target: /srv/salt

just in case:
  git.latest:
    - target: /srv/salt
    - name: https://github.com/Snergster/virl-salt.git
    - force: True
    - onfail:
      - git: first attempt
