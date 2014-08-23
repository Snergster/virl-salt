/usr/local/bin/vinstall:
  file.managed:
    - source: salt://files/vinstall.py
    - user: virl
    - group: virl
    - mode: 755
