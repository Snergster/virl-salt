/usr/local/bin/vinstall:
  file.managed:
    - source: salt://files/vinstall.py
    - user: virl
    - group: virl
    - mode: 0755

/srv/salt/host.sls:
  file.managed:
    - source: salt://host.sls
    - mode: 0755

/srv/salt/ntp.sls:
  file.managed:
    - source: salt://ntp.sls
    - mode: 0755


