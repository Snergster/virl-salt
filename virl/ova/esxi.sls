
esxi ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.238.esxi.ova
    - name: /home/virl/virl.0.9.238.esxi.ova
    - source_hash: md5=32d9e1f66bed7efd9c3673fc1c5a0802
    - user: virl
    - group: virl
    - mode: 0755

delete esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.238.esxi.ova
  - require:
    - file: esxi ova copy trial
