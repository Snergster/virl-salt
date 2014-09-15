/usr/local/bin/vinstall:
  file.managed:
    - source: salt://files/vinstall.py
    - user: virl
    - group: virl
    - mode: 0755

/home/virl/default.virl.ini:
  file.managed:
    - source: salt://files/vsettings.ini
    - user: virl
    - group: virl
    - mode: 0755

