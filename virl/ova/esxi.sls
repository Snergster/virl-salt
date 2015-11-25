
esxi ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.1.0.0.esxi.ova
    - name: /home/virl/virl.1.0.0.esxi.ova
    - source_hash: md5=fffa1485fe7c7d4479e382543391dd89
    - user: virl
    - group: virl
    - mode: 0755

delete esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.1.0.0.esxi.ova
  - require:
    - file: esxi ova copy trial
