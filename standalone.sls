/home/virl/virl.standalone:
  file.recurse:
    - user: virl
    - group: virl
    - file_mode: 755
    - dir_mode: 755
    - makedirs: True
    - source: "salt://virl/files/virl.standalone"
