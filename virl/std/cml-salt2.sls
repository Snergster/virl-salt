/srv/salt/cml:
  file.recurse:
    - source: "salt://cml/"
    - user: virl
    - group: virl
    - file_mode: 755