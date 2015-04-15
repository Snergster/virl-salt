
esxi ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.236.esxi.ova
    - name: /home/virl/virl.0.9.236.esxi.ova
    - source_hash: md5=819c5b6b129626864e7b8e88c5e95169
    - user: virl
    - group: virl
    - mode: 0755

delete esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.236.esxi.ova
  - require:
    - file: esxi ova copy trial
