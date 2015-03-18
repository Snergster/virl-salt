/home/virl/virl.standalone:
  file.recurse:
    - user: virl
    - group: virl
    - mode: 755
    - dir_mode: 755
    - makedirs: True
    - source: "salt://files/virl.standalone"
