
esxi ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.293.esxi.ova
    - name: /home/virl/virl.0.9.293.esxi.ova
    - source_hash: md5=e0c58fca93a41dd3a4f3451b20ae4b0f
    - user: virl
    - group: virl
    - mode: 0755

delete esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.293.esxi.ova
  - require:
    - file: esxi ova copy trial
