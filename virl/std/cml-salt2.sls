/srv/salt/cml:
  file.recurse:
    - source: "salt://cml/"
    - user: virl
    - group: virl
    - file_mode: 755

/srv/salt/std:
  file.recurse:
    - source: "salt://std/"
    - user: virl
    - group: virl
    - file_mode: 755