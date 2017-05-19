
/usr/local/bin/virl_setup:
  file.managed
    - source: salt://virl/files/virl_setup.py
    - mode: 755
