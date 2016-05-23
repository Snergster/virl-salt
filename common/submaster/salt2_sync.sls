include:
  - common.submaster.salt_sync

first attempt:
  git.latest:
    - name: https://github.com/Snergster/virl-salt.git
    - depth: 1
    - target: /srv/salt2/salt

just in case:
  git.latest:
    - target: /srv/salt2/salt
    - name: https://github.com/Snergster/virl-salt.git
    - depth: 1
    - force: True
    - onfail:
      - git: first attempt
