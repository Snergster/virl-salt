/usr/local/bin/vinstall:
  file.managed:
    - source: salt://files/vinstall.py
    - user: virl
    - group: virl
    - mode: 0755

/srv/salt/virl/host.sls:
  file.managed:
    - source: salt://virl/host.sls
    - makedirs: True
    - mode: 0755

/srv/salt/virl/ntp.sls:
  file.managed:
    - source: salt://virl/ntp.sls
    - makedirs: True
    - mode: 0755


