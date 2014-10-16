cleaning ssh off:
  pkg.removed:
    - order: 1
    - skip_verify: True
    - refresh: False
    - pkgs:
      - openssh-server

reapplying ssh:
  pkg.installed:
    - order: 2
    - skip_verify: True
    - refresh: False
    - pkgs:
      - openssh-server
