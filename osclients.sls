mypkgs:
  pkg.installed:
    - skip_verify: True
    - refresh: False
    - pkgs:
      - python-novaclient
      - python-glanceclient
      - python-keystoneclient
      - python-neutronclient

