/srv/salt/cml:
  file.recurse:
    - source: "salt://cml/"
    - user: virl
    - group: virl
    - exclude_pat: E@(.git)|(vmm)
    - file_mode: 755

/srv/salt/std:
  file.recurse:
    - source: "salt://std/"
    - user: virl
    - group: virl
    - exclude_pat: E@(.git)
    - file_mode: 755